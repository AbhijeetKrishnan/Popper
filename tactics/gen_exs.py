import argparse
import csv
import logging
import random
from typing import List, Optional, TextIO

import chess
import chess.engine
import chess.pgn

from fen_to_contents import fen_to_contents, uci_to_move
from util import LICHESS_2013, STOCKFISH, PathLike, get_engine, get_top_n_moves


logger = logging.getLogger(__name__)

BRATKO = 12 # Guid, Matej, and Ivan Bratko. "Computer analysis of world chess champions." ICGA journal 29.2 (2006): 65-73.
ROMERO = 7 # Romero, Oscar. "Computer analysis of world chess championship players." ICSEA 2019 (2019): 212.

def game_to_ex_list(game: Optional[chess.pgn.Game], opening_cutoff: int=ROMERO) -> List[chess.Board]:
    "Convert a game to a list of training examples"

    examples = []

    if not game:
        return examples
    
    node = game.next()
    while node:
        board = node.parent.board()
        move = node.move
        examples.append((board, move))
        node = node.next()

    return examples[opening_cutoff * 2:]

def sample_pgn(handle: TextIO, num_games, pos_per_game) -> List[chess.Board]:
    "Sample training examples from games in a PGN file"
    
    # obtain num_game offsets from list of games in PGN
    rand_state = random.getstate()

    offsets = []
    while True:
        offset = handle.tell()

        header = chess.pgn.read_headers(handle)
        if header is None:
            break

        termination = header.get("Termination")
        if termination in ["Normal", "Time forfeit"]:
            offsets.append(offset)
    sampled_offsets = random.sample(offsets, min(num_games, len(offsets)))
    logger.info(f'# of games = {len(offsets)}')
    logger.info(f'Sampled games = {len(sampled_offsets)}')

    # obtain pos_per_game examples from every game in sampled list of games
    random.setstate(rand_state) # to ensure same examples are picked for each game

    result = []
    for offset in sampled_offsets:
        handle.seek(offset)
        game = chess.pgn.read_game(handle)
        examples = game_to_ex_list(game)
        logger.info(f'Game: {game.headers["Site"]}, # of exs = {len(examples)}')
        sampled_examples = random.sample(examples, min(pos_per_game, len(examples)))
        result.extend(sampled_examples)
    return result

def gen_exs(exs_pgn_path: PathLike, num_games: int, pos_per_game: int, neg_to_pos_ratio: int=0, use_engine: bool=False, engine_path: Optional[PathLike]=None):
    
    with open(exs_pgn_path) as handle:
        sample_examples = sample_pgn(handle, num_games=num_games, pos_per_game=pos_per_game)
    
    if use_engine:
        with get_engine(engine_path) as engine:
            for position, move in sample_examples:
                moves = get_top_n_moves(engine, position, neg_to_pos_ratio + 1)
                if not moves:
                    continue
                top_move = moves[0]
                yield {'fen': position.fen(), 'uci': top_move.uci(), 'label': 1}
                for move in moves[1:]:
                    yield {'fen': position.fen(), 'uci': move.uci(), 'label': 0}
    else:
        for position, move in sample_examples:
            yield {'fen': position.fen(), 'uci': move.uci(), 'label': 1}

def parse_args():
    parser = argparse.ArgumentParser(description='Generate tactic training examples and write them to a csv file')
    parser.add_argument('example_file', type=str, help='File to write generated examples to')
    parser.add_argument('-i', '--pgn', dest='pgn_file', type=str, default=LICHESS_2013, help='PGN file containing games')
    parser.add_argument('-e', '--engine', dest='engine_path', default=STOCKFISH, help='Path to engine executable to use for recommending moves')
    parser.add_argument('-n', '--num-games', dest='num_games', type=int, default=10, help='Number of games to use')
    parser.add_argument('-p', '--pos-per-game', dest='pos_per_game', type=int, default=10, help='Number of positions to use per game')
    parser.add_argument('-r', '--ratio', dest='neg_to_pos_ratio', type=int, default=3, help='Ratio of negative to positive examples to generate')
    parser.add_argument('--seed', dest='seed', type=int, default=1, help='Seed to use for random generation')
    parser.add_argument('--use-engine', action='store_true', help='Use engine to generate moves for the examples')
    return parser.parse_args()

def main():
    args = parse_args()
    random.seed(args.seed)

    with open(args.example_file, 'w') as output:
        output.write(':- discontinuous pos/1.\n:- discontinuous neg/1.\n\n')
        for ex in gen_exs(args.pgn_file, args.num_games, args.pos_per_game, args.neg_to_pos_ratio, args.use_engine, args.engine_path):
            fen, move, label = ex['fen'], ex['uci'], ex['label']
            # print(fen, move, label)
            contents = fen_to_contents(fen)
            prolog_move = uci_to_move(move)
            if label == 1:
                example = f'pos(f({contents}, {prolog_move})).\n'
            else:
                example = f'neg(f({contents}, {prolog_move})).\n'
            output.write(example)

if __name__ == '__main__':
    main()
