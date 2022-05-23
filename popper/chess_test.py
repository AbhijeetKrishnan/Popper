import os
from contextlib import contextmanager
from typing import List, Union

import chess
import pyswip
from pyswip import Prolog
from pyswip.prolog import PrologError

from .core import Clause, Literal
from tactics.util import assert_legal_moves, chess_examples, fen_to_contents, get_prolog


class ChessTester():
    def __init__(self, settings):
        self.settings = settings
        self.prolog = get_prolog(settings.fpred)
        self.eval_timeout = settings.eval_timeout
        self.already_checked_redundant_literals = set()

        bk_pl_path = self.settings.bk_file

        self.pos = []
        self.neg = []
        for ex in chess_examples(self.settings.ex_file):
            if ex[2]:
                self.pos.append(ex)
            else:
                self.neg.append(ex)

        for x in [bk_pl_path]:
            if os.name == 'nt': # if on Windows, SWI requires escaped directory separators
                x = x.replace('\\', '\\\\')
            self.prolog.consult(x)

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
            for board, move, label in chess_examples(self.settings.ex_file):
                position = fen_to_contents(board.fen())
                from_sq = chess.square_name(move.from_square)
                to_sq = chess.square_name(move.to_square)

                # query the relation with the current example
                # TODO: eek, refactor this
                query = f"f({position}, {from_sq}, {to_sq})"

                if self.settings.fpred:
                    with assert_legal_moves(self.prolog, board):
                        try:
                            results = list(self.prolog.query(f'call_with_time_limit({self.eval_timeout}, {query})'))
                            if len(results) == 1:
                                prediction = True
                            else:
                                prediction = False
                        except PrologError:
                            print(f'% timeout occurred on {query}')
                            # don't use this example if timeout occurred
                            continue
                else:
                    try:
                        results = list(self.prolog.query(f'call_with_time_limit({self.eval_timeout}, {query})'))
                        if len(results) == 1:
                            prediction = True
                        else:
                            prediction = False
                    except PrologError:
                        prediction = False
                        # don't use this example if timeout occurred
                        continue
                
                if prediction and label:
                    tp += 1
                elif prediction and not label:
                    fp += 1
                elif not prediction and label:
                    fn += 1
                elif not prediction and not label:
                    tn += 1

        return tp, fn, tn, fp
