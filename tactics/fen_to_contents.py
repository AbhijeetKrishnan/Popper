#!/usr/bin/env python3

import sys
import re
from typing import List

import chess

def color_to_str(color: bool) -> str:
    if color:
        return 'white'
    else:
        return 'black'

def fen_to_contents(fen: str) -> str:
    "Convert a FEN position into a contents predicate"
    board = chess.Board()
    board.set_fen(fen)
    contents = []
    for square in chess.SQUARES:
        piece = board.piece_at(square)
        if piece:
            color = color_to_str(piece.color)
            piece_name = chess.piece_name(piece.piece_type)
            square = chess.square_name(square)
            contents.append(f'contents(piece({piece_name}, {color}), square({square}))')
    contents.append(f'turn({color_to_str(board.turn)})')
    for color in [chess.WHITE, chess.BLACK]:
        if board.has_kingside_castling_rights(color):
            contents.append(f'kingside_castle({color_to_str(color)})')
        if board.has_queenside_castling_rights(color):
            contents.append(f'queenside_castle({color_to_str(color)})')
    contents.append(f'halfmove_clock({board.halfmove_clock})')
    contents.append(f'fullmove({board.fullmove_number})')
    if board.ep_square:
        contents.append(f'ep_square({chess.square_name(board.ep_square)})')
    return f'[{", ".join(contents)}]'

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

def uci_to_move(uci: str) -> str:
    move = chess.Move.from_uci(uci)
    prolog_move = [chess.square_name(move.from_square), chess.square_name(move.to_square)]
    if move.promotion:
        prolog_move.append(chess.piece_name(move.promotion))
    return f'[{", ".join(map(str, prolog_move))}]'

def prolog_move_to_uci(prolog_move: List[str]) -> chess.Move:
    if len(prolog_move) == 2:
        return chess.Move.from_uci(prolog_move[0] + prolog_move[1])
    elif len(prolog_move) == 3:
        symbol = prolog_move[2][:1] if prolog_move[2] != 'knight' else 'n'
        return chess.Move.from_uci(prolog_move[0] + prolog_move[1] + symbol)

if __name__ == '__main__':
    # fen = sys.argv[1]
    # fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
    contents = ["contents(piece(rook, white), square(a1))", "contents(piece(knight, white), square(b1))", "contents(piece(bishop, white), square(c1))", "contents(piece(king, white), square(e1))", "contents(piece(knight, white), square(g1))", "contents(piece(rook, white), square(h1))", "contents(piece(pawn, white), square(d2))", "contents(piece(pawn, white), square(f2))", "contents(piece(pawn, white), square(g2))", "contents(piece(pawn, white), square(h2))", "contents(piece(pawn, white), square(c3))", "contents(piece(pawn, white), square(e3))", "contents(piece(pawn, white), square(b4))", "contents(piece(pawn, white), square(a5))", "contents(piece(pawn, black), square(e5))", "contents(piece(pawn, black), square(a6))", "contents(piece(knight, black), square(c6))", "contents(piece(pawn, black), square(d6))", "contents(piece(bishop, black), square(a7))", "contents(piece(pawn, black), square(b7))", "contents(piece(pawn, black), square(c7))", "contents(piece(knight, black), square(e7))", "contents(piece(pawn, black), square(g7))", "contents(piece(pawn, black), square(h7))", "contents(piece(rook, black), square(a8))", "contents(piece(king, black), square(e8))", "contents(piece(rook, black), square(h8))", "turn(white), kingside_castle(white)", "queenside_castle(white)", "kingside_castle(black)", "queenside_castle(black)", "halfmove_clock(1)", "fullmove(12)"]
    print(contents_to_board(contents).fen())