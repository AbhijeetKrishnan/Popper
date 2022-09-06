import argparse
import csv
import logging
import math
from collections.abc import Callable
from typing import Generator, List, Optional, Tuple

import chess
import chess.engine
import chess.pgn
import pyparsing
from pyswip import Prolog
from pyswip.prolog import Prolog
from tqdm import tqdm

from prolog_parser import create_parser, parse_result_to_str
from util import *

logger = logging.getLogger(__name__)
logger.propagate = False # https://stackoverflow.com/a/2267567

SUGGESTIONS_PER_TACTIC = 3
divergence_fn = lambda idx, error: error / math.log2(1 + (idx + 1))
avg_fn = lambda _, error: error

def evaluate(moves_a: List[Tuple[chess.Move, int]], moves_b: List[Tuple[chess.Move, int]], metric_fn: Callable[[int, float], float]) -> float:
    "Calculate a metric by comparing two lists of evaluated moves"
    metric: float = 0.0
    if len(moves_a) == 0 or len(moves_b) == 0:
        return metric
    for idx, (move_a, move_b) in enumerate(zip(moves_a, moves_b)):
        _, score_a = move_a
        _, score_b = move_b
        error = abs(score_b - score_a)
        metric += metric_fn(idx, error)
    return metric / min(len(moves_a), len(moves_b))

def get_tactic_match(prolog: Prolog, text: str, board: chess.Board, limit: int=3, time_limit_sec: Optional[int]=None, use_foreign_predicate: bool=False) -> Tuple[Optional[bool], Optional[List[chess.Move]]]:
    "Given the text of a Prolog-based tactic, and a position, check whether the tactic matched in the given position or and if so, what were the suggested moves"
    
    results = chess_query(prolog, text, board, limit=limit, time_limit_sec=time_limit_sec, use_foreign_predicate=use_foreign_predicate)
    if results is None:
        match, suggestions = None, None
    elif not results:
        match, suggestions = False, None
    else:
        match = True
        # convert suggestions to chess.Moves
        def suggestion_to_move(suggestion):
            from_sq = chess.parse_square(suggestion['From'])
            to_sq = chess.parse_square(suggestion['To'])
            return chess.Move(from_sq, to_sq)
        suggestions = list(map(suggestion_to_move, results))
        assert suggestions # suggestions list is not empty if tactic matches
    
    return match, suggestions

def get_tactic_evals(prolog: Prolog, tactic_text: str, board: chess.Board, limit: int, engine: chess.engine.SimpleEngine, args) -> Tuple[bool, List[Tuple[chess.Move, int]]]:
    "Obtain tactic suggestions and return their engine evaluations for a given position"
    
    match, suggestions = get_tactic_match(prolog, tactic_text, board, limit=limit, time_limit_sec=args.eval_timeout, use_foreign_predicate=args.fpred)
    logger.debug(f'Suggestions: {suggestions}')
    tactic_evals = []
    if match and suggestions:
        tactic_evals = get_evals(engine, board, suggestions, mate_score=args.mate_score)
    logger.debug(f'Match: {str(match)}, Evals: {str(tactic_evals)}')
    return match, tactic_evals

def print_metrics(metrics: dict, log_level=logging.INFO) -> None:
    logger.log(log_level, metrics)

def write_metrics(metrics_list: List[dict], csv_filename: str) -> None:
    "Write metrics to csv file for analysis"
    with open(csv_filename, 'w') as csv_file:
        field_names = list(metrics_list[0].keys())
        writer = csv.DictWriter(csv_file, fieldnames=field_names)
        writer.writeheader()
        for metrics in metrics_list:
            writer.writerow(metrics)

def calc_metrics(tactic_evals: List[Tuple[chess.Move, int]], ground_evals: List[Tuple[chess.Move, int]], **kwargs) -> dict:
    "Calculate metrics from evaluating a tactic against a position"

    board, move, label = kwargs['example']
    logger.debug(board)
    prefix = kwargs['prefix']

    metrics = {
        'match': 0,
        'num_suggestions': 0,
        'correct_move': 0,
        'tactic_text': kwargs['tactic_text'],
        'move': move.uci(),
        'position': board.fen()
    }

    if kwargs['match']:
        metrics['match'] = 1
        metrics[f'{prefix}_div'] = evaluate(tactic_evals, ground_evals, divergence_fn)
        metrics[f'{prefix}_avg'] = evaluate(tactic_evals, ground_evals, avg_fn)
        metrics['correct_move'] = int(move in [tactic_eval[0] for tactic_eval in tactic_evals])
        metrics['num_suggestions'] = len(tactic_evals)
    else:
        metrics['match'] = 0 if kwargs['match'] is False else 'n/a'
        metrics[f'{prefix}_div'] = 'n/a'
        metrics[f'{prefix}_avg'] = 'n/a'
        metrics[f'{prefix}_div'] = 'n/a'
        metrics[f'{prefix}_avg'] = 'n/a'
        metrics['correct_move'] = 'n/a'
        metrics['num_suggestions'] = 'n/a'
    
    print_metrics(metrics, log_level=logging.DEBUG)
    return metrics

def parse_args():
    parser = argparse.ArgumentParser(description='Calculate metrics for a set of chess tactics')
    parser.add_argument('tactics_file', type=str, help='file containing list of tactics')
    parser.add_argument('--log', dest='log_level', choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'], help='Set the logging level', default='INFO')
    parser.add_argument('-n', '--num_tactics', dest='tactics_limit', type=int, help='Number of tactics to analyze', default=None)
    parser.add_argument('-e', '--engine', dest='engine_path', default='STOCKFISH', choices=['STOCKFISH', 'MAIA1100', 'MAIA1600', 'MAIA1900'], help='Path to engine executable to use for calculating divergence')
    parser.add_argument('--pgn', dest='pgn_file', default=LICHESS_2013, help='Path to PGN file of positions to use for calculating divergence')
    parser.add_argument('--num-games', dest='num_games', type=int, default=10, help='Number of games to use')
    parser.add_argument('--pos-per-game', dest='pos_per_game', type=int, default=10, help='Number of positions to use per game')
    parser.add_argument('--data-path', dest='data_path', type=str, default='tactics/data/stats/metrics_data.csv', help='File path to which metrics should be written')
    parser.add_argument('--pos-list', dest='pos_list', type=str, help='Path to file contatining list of positions to use for calculating divergence')
    parser.add_argument('--fpred', default=False, action='store_true', help='Use legal_move as a foreign predicate')
    parser.add_argument('--eval-timeout', type=int, default=None, help='Prolog evaluation timeout in seconds')
    parser.add_argument('--mate-score', type=int, default=2000, help='Score to use to approximate a Mate in X evaluation')
    return parser.parse_args()

def create_logger(log_level):
    logging.basicConfig(level=getattr(logging, log_level))
    logger = logging.getLogger(__name__)
    fmt = logging.Formatter('[%(levelname)s] [%(asctime)s] %(funcName)s:%(lineno)d - %(message)s')
    hdlr = logging.FileHandler('info.log', encoding='utf-8')
    hdlr.setFormatter(fmt)
    hdlr.setLevel(logging.DEBUG)
    logger.addHandler(hdlr)
    return logger

def get_tactics(tactics_file: str) -> Generator[str, None, None]:
    "Generator for list of tactic text strings"

    prolog_parser = create_parser()
    with open(tactics_file) as hspace_handle:
        for line in hspace_handle:
            logger.debug(line)
            if line[0] == '%': # skip comments
                continue
            
            # Get tactic
            try:
                tactic = prolog_parser.parse_string(line)
            except pyparsing.exceptions.ParseException:
                logger.error(f'Parsing error on {line}')
                continue
            logger.debug(tactic)
            tactic_text = parse_result_to_str(tactic)
            logger.debug(tactic_text)
            yield tactic_text

def main():
    # Create argument parser
    args = parse_args()
    if args.engine_path == 'STOCKFISH':
        engine_path = STOCKFISH
    elif args.engine_path == 'MAIA1100':
        engine_path = get_lc0_cmd(LC0, MAIA_1100)
    elif args.engine_path == 'MAIA1600':
        engine_path = get_lc0_cmd(LC0, MAIA_1600)
    elif args.engine_path == 'MAIA1900':
        engine_path = get_lc0_cmd(LC0, MAIA_1900)

    # Create logger
    logger = create_logger(args.log_level)

    # Get list of training examples
    if args.pos_list:
        positions = chess_examples(args.pos_list)
    elif args.pgn_file:
        positions = positions_pgn(args.pgn_file, args.num_games, args.pos_per_game)
    training_examples = list(positions)
    tactics = list(get_tactics(args.tactics_file))
    if args.tactics_limit:
        tactics = tactic[:args.tactics_limit]
    
    # Calculate metrics for each tactic
    prolog = get_prolog(BK_FILE, args.fpred)
    metrics_list = []
    with get_engine(engine_path) as engine:
        for board, move, label in tqdm(training_examples, desc='Positions', unit='positions'):
            ground_evals = get_evals(engine, board, [move], mate_score=args.mate_score)
            ground_metrics = calc_metrics(ground_evals, ground_evals, example=(board, move, label), match=1, tactic_text='ground', prefix='tactic_ground')
            metrics_list.append(ground_metrics)
            for tactic_text in tqdm(tactics, desc='Tactics', unit='tactics', leave=False):
                match, tactic_evals = get_tactic_evals(prolog, tactic_text, board, SUGGESTIONS_PER_TACTIC, engine, args)
                metrics = calc_metrics(tactic_evals, ground_evals, example=(board, move, label), match=match, tactic_text=tactic_text, prefix='tactic_ground')
                metrics_list.append(metrics)
            best_move_evals = get_top_n_moves(engine, board, SUGGESTIONS_PER_TACTIC)
            best_move_metrics = calc_metrics(best_move_evals, ground_evals, example=(board, move, label), match=1, tactic_text='engine_best', prefix='tactic_ground')
            metrics_list.append(best_move_metrics)

    logger.info(f'% Calculated metrics for {len(tactics)} tactics')
    write_metrics(metrics_list, args.data_path)

if __name__ == '__main__':
    main()
