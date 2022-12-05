/** <module> A piece with type and color
 *
 * Defines predicates to represent a piece in chess.
 * A piece is represented with the predicate piece/2 as piece(TypeAtom, ColorAtom).
 * e.g., piece(king, white).
 *
 * A piece is allowed to be represented with the atom 'empty' to denote the absence of a piece in case of predicates
 * like piece_at/3.
 *
 * @author Abhijeet Krishnan
 * @copyright (c)2022 Abhijeet Krishnan.
 * @license All rights reserved. Used with permission.
 */
:- module(pieces, [
    piece/2, 
    piece_char/2, 
    pawn_start_rank/2
]).

:- use_module(colors).
:- use_module(piece_types).

/**
 * piece(+Type:p_type, +Color:color) is det
 *
 * Validate a piece.
 *
 * @param Type
 * @param Color
 */
piece(Type, Color) :-
    piece_type(Type),
    color(Color).

% convert between piece representation in FEN to piece/2 predicate
/**
 * piece_char(+PieceChar:char, -Piece:piece) is det
 *
 * Converts a character representation of a piece (as used in FEN) to a piece/2 predicate.
 *
 * @param PieceChar Character representation of a piece as used in FEN
 * @param Piece Resultant chess piece represented using piece/2
 */
piece_char('P', piece(pawn, white)).
piece_char('N', piece(knight, white)).
piece_char('B', piece(bishop, white)).
piece_char('R', piece(rook, white)).
piece_char('Q', piece(queen, white)).
piece_char('K', piece(king, white)).

piece_char('p', piece(pawn, black)).
piece_char('n', piece(knight, black)).
piece_char('b', piece(bishop, black)).
piece_char('r', piece(rook, black)).
piece_char('q', piece(queen, black)).
piece_char('k', piece(king, black)).

/**
 * pawn_start_rank(+Side:side, +Rank:int) is det
 *
 * Defines the start rank of a pawn in chess.
 *
 * @param Side
 * @param Rank
 */
pawn_start_rank(white, 2).
pawn_start_rank(black, 7).