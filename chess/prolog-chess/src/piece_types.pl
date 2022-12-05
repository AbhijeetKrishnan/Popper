/** <module> Chess piece types and associated string utilities
 *
 *  This module defines the various piece types in chess and string utilities for them.
 *
 *  @author Abhijeet Krishnan
 *  @copyright (c)2022 Abhijeet Krishnan.
 *  @license All rights reserved. Used with permission.
 */

/**
 * piece_type(+PieceType:p_type) is det
 * 
 * Defines all possible piece types in chess.
 *
 * @param PieceType The piece type, which may be any one in {pawn, knight, bishop, rook, queen, king}.
 */
:- module(piece_types, [
    piece_type/1, 
    promo_piece/1, 
    piece_type_str/2
]).

piece_type(pawn).
piece_type(knight).
piece_type(bishop).
piece_type(rook).
piece_type(queen).
piece_type(king).

/**
 * promo_piece(+PieceType:p_type) is det
 *
 * Defines all valid promo piece types in chess.
 *
 * @param PieceType
 */
promo_piece(knight).
promo_piece(bishop).
promo_piece(rook).
promo_piece(queen).

/**
 * piece_type_string(+PieceType:p_type, -String:str) is det
 * 
 * Produces the string representation of a piece for display
 * 
 * @param PieceType The piece type
 * @param String The string representation of PieceType
 */
piece_type_str(pawn,   "P").
piece_type_str(knight, "N").
piece_type_str(bishop, "B").
piece_type_str(rook,   "R").
piece_type_str(queen,  "Q").
piece_type_str(king,   "K").