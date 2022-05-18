import csv
import os
from contextlib import contextmanager
from typing import List, Union

import chess
import pyswip
from pyswip import Prolog
from pyswip.prolog import PrologError

from .core import Clause, Literal


def convert_side(side: Union[str, bool]) -> Union[bool, str]:
    if isinstance(side, bool):
        side_str = 'white' if side == chess.WHITE else 'black'
        return side_str
    elif isinstance(side, str):
        side_val = chess.WHITE if side == 'white' else chess.BLACK
        return side_val

def fen_to_contents(fen: str) -> str:
    "Convert a FEN position into a contents predicate"

    board = chess.Board()
    board.set_fen(fen)
    board_str_list = []
    for square in chess.SQUARES:
        piece = board.piece_at(square)
        if piece:
            color = convert_side(piece.color)
            piece_name = chess.piece_name(piece.piece_type)
            row = chess.square_rank(square) + 1
            col = chess.square_file(square) + 1
            board_str_list.append(f'contents({color}, {piece_name}, {col}, {row})')

    side_str = convert_side(board.turn)
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

def parse_piece(name: str) -> chess.Piece:
    name = name.lower()
    if name == 'pawn':
        return chess.PAWN
    elif name == 'knight':
        return chess.KNIGHT
    elif name == 'bishop':
        return chess.BISHOP
    elif name == 'rook':
        return chess.ROOK
    elif name == 'queen':
        return chess.QUEEN
    elif name == 'king':
        return chess.KING

def convert_pos_to_board(pos: List[pyswip.easy.Functor]) -> chess.Board:
    "Convert a list of contents/4 predicates into a board that can be used to generate legal moves"

    board = chess.Board(None)
    for predicate in pos:
        predicate_name = predicate.name.value
        if predicate_name == 'contents':
            side_str = predicate.args[0].value
            piece_str = predicate.args[1].value
            #code.interact(local=locals())
            file = predicate.args[2]
            rank = predicate.args[3]

            piece = chess.Piece(parse_piece(piece_str), convert_side(side_str))
            square = chess.square(file - 1, rank - 1)
            board.set_piece_at(square, piece)
        elif predicate_name == 'turn':
            side_str = predicate.args[0].value
            side = convert_side(side_str)
            board.turn = side
        elif predicate_name == 'kingside_castle':
            side_str = predicate.args[0].value
            side = convert_side(side_str)
            if side == chess.WHITE:
                board.castling_rights |= chess.BB_H1
            else:
                board.castling_rights |= chess.BB_H8
        elif predicate_name == 'queenside_castle':
            side_str = predicate.args[0].value
            side = convert_side(side_str)
            if side == chess.WHITE:
                board.castling_rights |= chess.BB_A1
            else:
                board.castling_rights |= chess.BB_A8
        else:
            pass
    return board

# https://stackoverflow.com/a/63156085
def legal_move(_from, to, pos, handle):
    "Implementation of a foreign predicate which unifies with legal moves in the position"

    control = pyswip.core.PL_foreign_control(handle)

    index = None
    return_value = False

    if control == pyswip.core.PL_FIRST_CALL: # First call of legal_move
        index = 0
    
    if control == pyswip.core.PL_REDO:  # Subsequent call of legal_move
        last_index = pyswip.core.PL_foreign_context(handle)  # retrieve the index of the last call
        index = last_index + 1

    if control == pyswip.core.PL_PRUNED:  # A cut has destroyed the choice point
        return False
    
    board = convert_pos_to_board(pos)
    legal_moves = list(board.legal_moves)
    if 0 <= index < len(legal_moves):
        move = legal_moves[index]
        _from.unify(chess.square_name(move.from_square))
        to.unify(chess.square_name(move.to_square))
        return_value = pyswip.core.PL_retry(index)

    return return_value

def get_prolog() -> pyswip.prolog.Prolog:
    "Create the Prolog object and initialize it for the tactic-unification process"

    pyswip.registerForeign(legal_move, arity=3, flags=pyswip.core.PL_FA_NONDETERMINISTIC)
    prolog = pyswip.Prolog()
    return prolog

class ChessTester():
    def __init__(self, settings):
        self.settings = settings
        self.prolog = get_prolog()
        self.eval_timeout = settings.eval_timeout
        self.already_checked_redundant_literals = set()

        bk_pl_path = self.settings.bk_file

        self.pos = []
        self.neg = []
        for ex in self.chess_examples():
            if ex[2]:
                self.pos.append(ex)
            else:
                self.neg.append(ex)

        for x in [bk_pl_path]:
            if os.name == 'nt': # if on Windows, SWI requires escaped directory separators
                x = x.replace('\\', '\\\\')
            self.prolog.consult(x)

    def chess_examples(self):
        chess_exs_path = self.settings.ex_file # csv file of (FEN position, UCI move, label)
        with open(chess_exs_path) as exs_file:
            exs_reader = csv.DictReader(exs_file)
            for row in exs_reader:
                board = chess.Board()
                board.set_fen(row['fen'])
                move = chess.Move.from_uci(row['uci'])
                label = bool(int(row['label']))
                yield (board, move, label)

    @contextmanager
    def using(self, rules):
        current_clauses = set()
        try:
            for rule in rules:
                (head, body) = rule
                self.prolog.assertz(Clause.to_code(Clause.to_ordered(rule)))
                current_clauses.add((head.predicate, head.arity))
            yield
        finally:
            for predicate, arity in current_clauses:
                args = ','.join(['_'] * arity)
                self.prolog.retractall(f'{predicate}({args})')

    def check_redundant_literal(self, program):
        for clause in program:
            k = Clause.clause_hash(clause)
            if k in self.already_checked_redundant_literals:
                continue
            self.already_checked_redundant_literals.add(k)
            (head, body) = clause
            C = f"[{','.join(('not_'+ Literal.to_code(head),) + tuple(Literal.to_code(lit) for lit in body))}]"
            res = list(self.prolog.query(f'redundant_literal({C})'))
            if res:
                yield clause

    def check_redundant_clause(self, program):
        # AC: if the overhead of this call becomes too high, such as when learning programs with lots of clauses, we can improve it by not comparing already compared clauses
        prog = []
        for (head, body) in program:
            C = f"[{','.join(('not_'+ Literal.to_code(head),) + tuple(Literal.to_code(lit) for lit in body))}]"
            prog.append(C)
        prog = f"[{','.join(prog)}]"
        return list(self.prolog.query(f'redundant_clause({prog})'))

    def is_non_functional(self, program):
        with self.using(program):
            return list(self.prolog.query(f'non_functional.'))

    def test(self, rules):
        tp, fn, tn, fp = 0, 0, 0, 0

        with self.using(rules):
            for board, move, label in self.chess_examples():
                position = fen_to_contents(board.fen())
                from_sq = chess.square_name(move.from_square)
                to_sq = chess.square_name(move.to_square)
                
                # query the relation with the current example
                query = f"f({position}, {from_sq}, {to_sq})"
                try:
                    results = list(self.prolog.query(f'call_with_time_limit({self.eval_timeout}, {query})'))
                    if len(results) == 1:
                        prediction = True
                    else:
                        prediction = False
                except PrologError:
                    prediction = False
                
                if prediction and label:
                    tp += 1
                elif prediction and not label:
                    fp += 1
                elif not prediction and label:
                    fn += 1
                elif not prediction and not label:
                    tn += 1

        return tp, fn, tn, fp
