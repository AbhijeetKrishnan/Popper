import csv
from multiprocessing import context
import os
from contextlib import contextmanager

import chess
from pyswip import Prolog
from pyswip.prolog import PrologError

from .core import Clause

def _fen_to_contents(fen: str) -> str:
    "Convert a FEN position into a contents predicate"
    board = chess.Board()
    board.set_fen(fen)
    piece_str_list = []
    for square in chess.SQUARES:
        piece = board.piece_at(square)
        if piece:
            color = 'white' if piece.color else 'black'
            piece_name = chess.piece_name(piece.piece_type)
            row = chess.square_rank(square) + 1
            col = chess.square_file(square) + 1
            piece_str_list.append(f'contents({color}, {piece_name}, {col}, {row})')
    return f'[{", ".join(piece_str_list)}]'


class ChessTester():
    def __init__(self, settings):
        self.settings = settings
        self.prolog = Prolog()
        self.eval_timeout = settings.eval_timeout

        bk_pl_path = self.settings.bk_file

        for x in [bk_pl_path]:
            if os.name == 'nt': # if on Windows, SWI requires escaped directory separators
                x = x.replace('\\', '\\\\')
            self.prolog.consult(x)

    def chess_examples(self):
        chess_exs_path = self.settings.exs_file # csv file of (FEN position, UCI move, pos/neg)
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

    @contextmanager
    def _legal_moves(self, board):
        position = _fen_to_contents(board)
        try:
            for legal_move in board.legal_moves:
                legal_from_sq = chess.square_name(legal_move.from_square)
                legal_to_sq = chess.square_name(legal_move.to_square)
                legal_move_pred = f'legal_move({legal_from_sq}, {legal_to_sq}, {position})'
                self.prolog.assertz(legal_move_pred)
            yield
        finally:
            self.prolog.retractall('legal_move(_, _, _)')

    def chess_test(self, rules):
        tp, fp, tn, fn = 0, 0, 0, 0

        with self.using(rules):
            for board, move, label in self.chess_examples():
                position = _fen_to_contents(board)
                from_sq = chess.square_name(move.from_square)
                to_sq = chess.square_name(move.to_square)
                
                with self._legal_moves(board):
                    # query the relation with the current example
                    query = f"f({position}, {from_sq}, {to_sq})"
                    try:
                        results = list(self.prolog.query(f'call_with_time_limit({self.eval_timeout}, {query})'))
                        if next(results, None) == {}:
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
                    
        return tp, fp, tn, fn
