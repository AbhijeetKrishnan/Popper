import csv
import logging
import os
from contextlib import contextmanager
from typing import Generator, List, Optional, Tuple, Union

import chess
import chess.engine
import chess.pgn
import pyswip

PathLike = Union[str, List[str]]

BK_FILE = os.path.join('chess', 'bk.pl')

LICHESS_2013 = os.path.join('tactics', 'data', 'lichess_db_standard_rated_2013-01.pgn')

MAIA_1100 = os.path.join('tactics', 'bin', 'maia_weights', 'maia-1100.pb')
MAIA_1600 = os.path.join('tactics', 'bin', 'maia_weights', 'maia-1600.pb')
MAIA_1900 = os.path.join('tactics', 'bin', 'maia_weights', 'maia-1900.pb')

STOCKFISH = os.path.join('tactics', 'bin', 'stockfish_14_x64')
LC0 = os.path.join('tactics', 'bin', 'lc0', 'build', 'release', 'lc0')

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

def fen_to_contents(fen: str) -> str:
    "Convert a FEN position into a contents predicate"

    board = chess.Board()
    board.set_fen(fen)
    board_str_list = []
    for square in chess.SQUARES:
        piece = board.piece_at(square)
        if piece:
            color = side_to_str(piece.color)
            piece_name = chess.piece_name(piece.piece_type)
            row = chess.square_rank(square) + 1
            col = chess.square_file(square) + 1
            board_str_list.append(f'contents({color}, {piece_name}, {col}, {row})')

    side_str = side_to_str(board.turn)
    turn_pred = f'turn({side_str})'
    board_str_list.append(turn_pred)

    castling_preds = []
    for side, side_str in zip([chess.WHITE, chess.BLACK], ['white', 'black']):
        if board.has_kingside_castling_rights(side):
            castling_preds.append(f'kingside_castle({side_str})')
        if board.has_queenside_castling_rights(side):
            castling_preds.append(f'queenside_castle({side_str})')
    board_str_list.extend(castling_preds)

    return f'[{", ".join(board_str_list)}]'

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

def get_evals(engine: chess.engine.SimpleEngine, board: chess.Board, suggestions: List[chess.Move], mate_score: int=2000) -> List[Tuple[chess.Move, int]]:
    "Obtain engine evaluations for a list of moves in a given position"

    evals = []
    for move in suggestions:
        tmp_board = chess.Board(board.fen())
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

def get_top_n_moves(engine: chess.engine.SimpleEngine, board: chess.Board, n: int, mate_score: int=2000) -> List[chess.Move]:
    "Get the top-n engine-recommended (and evaluated) moves for a given position"

    analysis = engine.analyse(board, limit=chess.engine.Limit(depth=1), multipv=n, game=object())
    top_results = [(root['pv'][0], root['score'].relative.score(mate_score=mate_score)) for root in analysis]
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

def convert_pos_to_board(pos: List[pyswip.easy.Functor]) -> chess.Board:
    "Convert a list of contents/4 predicates into a board that can be used to generate legal moves"

    board = chess.Board(None)
    for predicate in pos:
        predicate_name = predicate.name.value
        side_str = predicate.args[0].value
        side = str_to_side(side_str)
        if predicate_name == 'contents':
            piece_str = predicate.args[1].value
            file = predicate.args[2]
            rank = predicate.args[3]
            piece = chess.Piece(parse_piece(piece_str), side)
            square = chess.square(file - 1, rank - 1)
            board.set_piece_at(square, piece)
        elif predicate_name == 'turn':
            board.turn = side
        elif predicate_name == 'kingside_castle':
            if side == chess.WHITE:
                board.castling_rights |= chess.BB_H1
            else:
                board.castling_rights |= chess.BB_H8
        elif predicate_name == 'queenside_castle':
            if side == chess.WHITE:
                board.castling_rights |= chess.BB_A1
            else:
                board.castling_rights |= chess.BB_A8
        else:
            logger.error(f'Unknown predicate in position list: {predicate_name}')
    return board

# https://stackoverflow.com/a/63156085
def legal_move(_from, to, pos, handle):
    "Implementation of a foreign predicate which unifies with legal moves in the position"
    control = pyswip.core.PL_foreign_control(handle)

    index = None
    return_value = False
    board = convert_pos_to_board(pos)
    legal_moves = list(board.legal_moves)

    if control == pyswip.core.PL_FIRST_CALL: # First call of legal_move
        index = 0
        
    if control == pyswip.core.PL_REDO:  # Subsequent call of legal_move
        last_index = pyswip.core.PL_foreign_context(handle)  # retrieve the index of the last call
        index = last_index + 1

    if control == pyswip.core.PL_PRUNED:  # A cut has destroyed the choice point
        return False
        
    if isinstance(_from, pyswip.easy.Variable):
        if 0 <= index < len(legal_moves):
            move = legal_moves[index]
            from_atom = pyswip.easy.Atom(chess.square_name(move.from_square))
            to_atom = pyswip.easy.Atom(chess.square_name(move.to_square))
            _from.unify(from_atom)
            to.unify(to_atom)
            return_value = pyswip.core.PL_retry(index)
    elif isinstance(_from, pyswip.easy.Atom):
        target = chess.Move(chess.parse_square(_from.value), chess.parse_square(to.value))
        return_value = target in legal_moves

    return return_value

def get_prolog(bk_path: PathLike=None, use_foreign_predicate: bool=False) -> pyswip.prolog.Prolog:
    "Create the Prolog object and initialize it for the tactic-unification process"

    if use_foreign_predicate:
        pyswip.registerForeign(legal_move, arity=3, flags=pyswip.core.PL_FA_NONDETERMINISTIC)
    prolog = pyswip.Prolog()
    if bk_path:
        prolog.consult(bk_path)
    return prolog

@contextmanager
def assert_legal_moves(prolog: pyswip.prolog.Prolog, board: chess.Board):
    position = fen_to_contents(board.fen())
    try:
        for legal_move in board.legal_moves:
            legal_from_sq = chess.square_name(legal_move.from_square)
            legal_to_sq = chess.square_name(legal_move.to_square)
            legal_move_pred = f'legal_move({legal_from_sq}, {legal_to_sq}, {position})'
            logger.debug(f'Asserting legal_move {legal_move_pred}')
            prolog.assertz(legal_move_pred)
        yield
    finally:
        prolog.retractall('legal_move(_, _, _)')

def chess_query(prolog: pyswip.prolog.Prolog, tactic_text: str, board: chess.Board, limit: int=-1, move: Optional[chess.Move]=None, time_limit_sec: Optional[int]=None, use_foreign_predicate: bool=False) -> Optional[list]:
    "Given the text of a Prolog-based tactic, and a position, check whether the tactic matched in the given position or and if so, what were the suggested moves"
    # TODO: eek, refactor this
    position = fen_to_contents(board.fen())
    try:
        prolog.assertz(tactic_text)
        if use_foreign_predicate:
            if move:
                from_sq = chess.square_name(move.from_square)
                to_sq = chess.square_name(move.to_square)
                query = f"f({position}, {from_sq}, {to_sq})"
            else:
                query = f"f({position}, From, To)"
                
            if time_limit_sec:
                query = f"call_with_time_limit({time_limit_sec}, {query})"
                logger.debug(f'Launching query: {query} with time limit: {time_limit_sec}s')
            else:
                logger.debug(f'Launching query: {query} with no time limit')
            results = list(prolog.query(f'{query}', maxresult=limit))
            logger.debug(f'Results: {results}')
            prolog.retract(tactic_text)
        else:
            with assert_legal_moves(prolog, board):
                if move:
                    from_sq = chess.square_name(move.from_square)
                    to_sq = chess.square_name(move.to_square)
                    query = f"f({position}, {from_sq}, {to_sq})"
                else:
                    query = f"f({position}, From, To)"
                    
                if time_limit_sec:
                    query = f"call_with_time_limit({time_limit_sec}, {query})"
                    logger.debug(f'Launching query: {query} with time limit: {time_limit_sec}s')
                else:
                    logger.debug(f'Launching query: {query} with no time limit')
                results = list(prolog.query(f'{query}', maxresult=limit))
                logger.debug(f'Results: {results}')
                prolog.retract(tactic_text)
        return results
    except pyswip.prolog.PrologError as e:
        logger.warning(str(e))
        logger.warning(f'timeout after {time_limit_sec}s on tactic {tactic_text}')
        return None

if __name__ == '__main__':
    tactic = 'f(A,B,C):-legal_move(B,C,A),attacks(B,D,A),different_pos(B,D)'
    contents = 'contents(white, king, 5, 3), contents(white, pawn, 7, 3), contents(white, pawn, 1, 4), contents(white, pawn, 5, 4), contents(white, pawn, 8, 4), contents(white, pawn, 2, 5), contents(black, king, 5, 5), contents(black, pawn, 8, 5), contents(black, pawn, 4, 6), contents(black, pawn, 7, 6), contents(black, pawn, 1, 7), contents(black, pawn, 2, 7), contents(black, pawn, 7, 7), turn(black)]'
    prolog = get_prolog(BK_FILE)
    board = chess.Board()
    results = chess_query(prolog, tactic, board)
    print(results)