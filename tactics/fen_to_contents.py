#!/usr/bin/env python3

import sys
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
    contents.append(f'halfmove_number({board.halfmove_clock})')
    contents.append(f'fullmove({board.fullmove_number})')
    if board.ep_square:
        contents.append(f'ep_square({chess.square_name(board.ep_square)})')
    return f'[{", ".join(contents)}]'

def uci_to_move(uci: str) -> str:
    move = chess.Move.from_uci(uci)
    prolog_move = [chess.square_name(move.from_square), chess.square_name(move.to_square)]
    if move.promotion:
        prolog_move.append(chess.piece_name(move.promotion))
    return f'[{", ".join(map(str, prolog_move))}]'

if __name__ == '__main__':
    fen = sys.argv[1]
    # fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
    print(fen_to_contents(fen))