/** <module> A piece with type and color
 *
 * Defines predicates to represent a piece in chess.
 * A piece is represented with the predicate piece/2 as piece(TypeAtom, ColorAtom).
 * e.g., piece(king, white).
 *
 * @author Abhijeet Krishnan
 * @copyright (c)2022 Abhijeet Krishnan.
 * @license All rights reserved. Used with permission.
 */

:- ['colors.pl'].
:- ['piece_types.pl'].

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