#!/usr/bin/env python3

from collections.abc import Iterable
import os
import re
import sys
from typing import List

import chess, chess.pgn
import pyswip

prolog = pyswip.Prolog()
prolog.consult('load.pl')


def contents_to_board(contents: List[str]) -> chess.Board:
    board = chess.Board().empty()
    for predicate in contents:
        if m := re.fullmatch(r'contents\(piece\((?P<type>\w+), (?P<color>white|black)\), square\((?P<square>[a-h][1-9])\)\)', predicate):
            symbol = m['type'][:1] if m['type'] != 'knight' else 'n'
            piece = chess.Piece.from_symbol(symbol if m['color'] == 'black' else symbol.upper())
            square = chess.parse_square(m['square'])
            board.set_piece_at(square, piece)
        if m := re.fullmatch(r'turn\((?P<color>white|black)\)', predicate):
            side = chess.WHITE if m['color'] == 'white' else chess.BLACK
            board.turn = side
        if m := re.fullmatch(r'halfmove_clock\((?P<val>\d+)\)', predicate):
            board.halfmove_clock = int(m['val'])
        if m := re.fullmatch(r'fullmove\((?P<val>\d+)\)', predicate):
            board.fullmove_number = int(m['val'])
        if m := re.fullmatch(r'en_passant\((?P<ep_square>[a-h][1-9])\)', predicate):
            ep_square = chess.parse_square(m['ep_square'])
            board.ep_square = ep_square
        if m := re.fullmatch(r'kingside_castle\((?P<color>white|black)\)', predicate):
            side = chess.WHITE if m['color'] == 'white' else chess.BLACK
            if side == chess.WHITE:
                board.castling_rights |= chess.BB_H1
            else:
                board.castling_rights |= chess.BB_H8
        if m := re.fullmatch(r'queenside_castle\((?P<color>white|black)\)', predicate):
            side = chess.WHITE if m['color'] == 'white' else chess.BLACK
            if side == chess.WHITE:
                board.castling_rights |= chess.BB_A1
            else:
                board.castling_rights |= chess.BB_A8
    return board


def push_prolog(board: chess.Board, move: chess.Move) -> chess.Board:
    prolog_move = move_to_prolog(move)
    make_move_query = f'set_board_fen("{board.fen()}", Board), make_move(Board, [{", ".join(prolog_move)}], NewBoard)'
    contents = next(prolog.query(make_move_query))['NewBoard']
    new_board = contents_to_board(contents)
    return new_board

def move_to_prolog(move: chess.Move) -> List[str]:
    prolog_move = [chess.square_name(move.from_square), chess.square_name(move.to_square)]
    if move.promotion:
        prolog_move.append(chess.piece_name(move.promotion))
    return list(map(str, prolog_move))

def prolog_move_to_uci(prolog_move: List[str]) -> chess.Move:
    if len(prolog_move) == 2:
        return chess.Move.from_uci(prolog_move[0] + prolog_move[1])
    elif len(prolog_move) == 3:
        symbol = prolog_move[2][:1] if prolog_move[2] != 'knight' else 'n'
        return chess.Move.from_uci(prolog_move[0] + prolog_move[1] + symbol)

def get_prolog_legal_moves(board: chess.Board) -> Iterable[chess.Move]:
    legal_moves_query = f'set_board_fen("{board.fen()}", Board), findall(Move, legal_move(Board, Move), LegalMoves)'
    legal_moves_res = next(prolog.query(legal_moves_query))['LegalMoves']
    legal_moves = map(lambda move: prolog_move_to_uci(move), legal_moves_res)
    return legal_moves


if __name__ == '__main__':
    PGN_PATH = os.path.join(os.path.expanduser('~'), 'phd/interpretable-chess-tactics/tactics/data/lichess_db_standard_rated_2013-01.pgn')
    pgn = open(PGN_PATH, 'r')

    while game := chess.pgn.read_game(pgn):
        prolog_board = chess.Board()
        python_board = chess.Board()

        for move in game.mainline_moves():
            prolog_board = push_prolog(prolog_board, move)
            python_board.push(move)

            if prolog_board.fen() != python_board.fen():
                python_board.pop()
                prev_board_fen = python_board.fen()
                python_board.push(move)
                print(f'Previous board: {prev_board_fen}\nMove: {move.uci()}\nProlog: {prolog_board.fen()}\nPython: {python_board.fen()}')
                sys.exit(1)
                

            prolog_legal = ', '.join([move.uci() for move in sorted(list(get_prolog_legal_moves(prolog_board)), key=lambda move: move.uci())])
            python_legal = ', '.join([move.uci() for move in sorted(list(python_board.legal_moves), key=lambda move: move.uci())])
            
            if prolog_legal != python_legal:
                print(f'{python_board.fen()}\nProlog: {prolog_legal}\nPython: {python_legal}')
                sys.exit(1)
