import csv
import logging
import os
from contextlib import contextmanager
from typing import Generator, List, Optional, Tuple, Union

import chess
import chess.engine
import chess.pgn
import pyswip

from fen_to_contents import fen_to_contents, uci_to_move, prolog_move_to_uci

PathLike = Union[str, List[str]]

BK_FILE = os.path.join('chess', 'bk.pl')

LICHESS_2013 = os.path.join('tactics', 'data', 'lichess_db_standard_rated_2013-01.pgn')

MAIA_1100 = os.path.join('tactics', 'bin', 'maia_weights', 'maia-1100.pb')
MAIA_1600 = os.path.join('tactics', 'bin', 'maia_weights', 'maia-1600.pb')
MAIA_1900 = os.path.join('tactics', 'bin', 'maia_weights', 'maia-1900.pb')

STOCKFISH = os.path.join('tactics', 'bin', 'stockfish_14_x64')
LC0 = os.path.join('tactics', 'bin', 'lc0', 'build', 'release', 'lc0')

ILLEGAL_MOVE_SCORE = -1000
MATE_SCORE = 2000

logger = logging.getLogger(__name__)

def get_lc0_cmd(lc0_path: str, weights_path: str) -> List[str]:
    return [lc0_path, f'--weights={weights_path}']

@contextmanager
def get_engine(engine_path: PathLike):
    try:
        engine = chess.engine.SimpleEngine.popen_uci(engine_path)
        yield engine
    except chess.engine.EngineError as e:
        logger.warning(str(e))
        pass
    finally:
        engine.close()

def side_to_str(side: bool) -> str:
    return 'white' if side == chess.WHITE else 'black'

def str_to_side(side_str: str) -> bool:
    return chess.WHITE if side_str.lower() == 'white' else chess.BLACK

def positions_pgn(pgn_file: PathLike, num_games: int=10, pos_per_game: int=10) -> Generator[chess.Board, None, None]:
    "Generator to yield list of positions from games in a PGN file"
    with open(pgn_file) as pgn_file_handle:
        curr_games = 0
        while game := chess.pgn.read_game(pgn_file_handle):
            curr_positions = 0
            node = game.next() # skip start position
            while node and not node.is_end():
                board = node.board()
                yield board
                curr_positions += 1
                if pos_per_game and curr_positions >= pos_per_game:
                    break
                node = node.next()
            curr_games += 1
            if num_games and curr_games >= num_games:
                break

def positions_list(pos_list: PathLike) -> Generator[chess.Board, None, None]:
    "Generator to yield positions listed in FEN notation in a file"
    with open(pos_list) as pos_list_handle:
        for line in pos_list_handle:
            board = chess.Board()
            board.set_board_fen(line)
            yield board

def chess_examples(chess_exs_path: PathLike) -> Generator[Tuple[chess.Board, chess.Move, bool], None, None]:
    with open(chess_exs_path) as exs_file:
        exs_reader = csv.DictReader(exs_file)
        for row in exs_reader:
            board = chess.Board()
            board.set_fen(row['fen'])
            move = chess.Move.from_uci(row['uci'])
            label = bool(int(row['label']))
            yield (board, move, label)

def get_evals(engine: chess.engine.SimpleEngine, board: chess.Board, suggestions: List[chess.Move], mate_score: int=MATE_SCORE) -> List[Tuple[chess.Move, int]]:
    "Obtain engine evaluations for a list of moves in a given position"

    evals = []
    for move in suggestions:
        tmp_board = chess.Board(board.fen())
        if move not in tmp_board.legal_moves:
            evals.append((move, ILLEGAL_MOVE_SCORE))
            continue
        tmp_board.push(move)
        if tmp_board.outcome() is not None:
            move_score = mate_score if tmp_board.is_checkmate() else -mate_score
            evals.append((move, move_score))
            continue
        eval = engine.analyse(tmp_board, limit=chess.engine.Limit(nodes=1), game=object()) # https://stackoverflow.com/a/66251120
        orig_turn = board.turn
        if 'pv' in eval:
            curr_score = eval['score'].pov(orig_turn)
            move_score = curr_score.score(mate_score=mate_score)
            evals.append((move, move_score))
    return evals

def get_top_n_moves(engine: chess.engine.SimpleEngine, board: chess.Board, n: int) -> List[chess.Move]:
    "Get the top-n engine-recommended moves for a given position"

    analysis = engine.analyse(board, limit=chess.engine.Limit(depth=1), multipv=n, game=object())
    top_results = [root['pv'][0] for root in analysis]
    top_n_results = top_results[:n]
    return top_n_results

def parse_piece(name: str) -> int:
    name = name.lower()
    if name == 'pawn':
        ret_val = chess.PAWN
    elif name == 'knight':
        ret_val = chess.KNIGHT
    elif name == 'bishop':
        ret_val = chess.BISHOP
    elif name == 'rook':
        ret_val = chess.ROOK
    elif name == 'queen':
        ret_val = chess.QUEEN
    elif name == 'king':
        ret_val = chess.KING
    return ret_val

def get_prolog(bk_path: PathLike=None) -> pyswip.prolog.Prolog:
    "Create the Prolog object and initialize it for the tactic-unification process"

    prolog = pyswip.Prolog()
    if bk_path:
        prolog.consult(bk_path)
    return prolog

def chess_query(prolog: pyswip.prolog.Prolog, tactic_text: str, board: chess.Board, limit: int=-1, move: Optional[chess.Move]=None, time_limit_sec: Optional[int]=None, use_foreign_predicate: bool=False) -> Optional[list]:
    "Given the text of a Prolog-based tactic, and a position, check whether the tactic matched in the given position or and if so, what were the suggested moves"
    position = fen_to_contents(board.fen())
    try:
        prolog.assertz(tactic_text)
        if move:
            query = f"f({position}, {uci_to_move(move)})"
        else:
            query = f"f({position}, Move)"
        if time_limit_sec:
            query = f"call_with_time_limit({time_limit_sec}, {query})"
            logger.debug(f'Launching query: {query} for tactic: {tactic_text} with time limit: {time_limit_sec}s')
        else:
            logger.debug(f'Launching query: {query} for tactic: {tactic_text} with no time limit')
        results = list(prolog.query(f'{query}', maxresult=limit))
        logger.debug(f'Results: {results}')
        results = list(set(list(map(lambda ele: prolog_move_to_uci(ele['Move']), results))))
        prolog.retract(tactic_text)
        return results
    except pyswip.prolog.PrologError as e:
        logger.warning(str(e))
        logger.warning(f'timeout after {time_limit_sec}s on tactic {tactic_text}')
        results = None
        prolog.retract(tactic_text)
        return results

if __name__ == '__main__':
    tactic = 'f(A,B):-pseudo_legal_move(A,B),make_move(A,B,D),make_move(D,B,C),make_move(C,B,D)'
    board = chess.Board('r3k2r/bpp1n1pp/p1np4/P3p3/1P6/2P1P3/3P1PPP/RNB1K1NR w Qkq - 0 12')
    prolog = get_prolog(BK_FILE)
    results = chess_query(prolog, tactic, board)
    print(results)