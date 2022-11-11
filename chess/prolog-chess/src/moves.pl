/** <module> Moves in chess
 *
 * Represents a move from a square to a square and possibly the promotion piece type.
 * Drops and null moves are NOT supported.
 *
 * A move is represented by a list of two or three atoms
 * The first element if the From square - the square the move is made from e.g., e2
 * The second element is the To square - the square the move is made to e.g., e4
 * The third (optional) element is the Promo piece - the piece to which the current piece (pawn) is being promoted e.g. queen
 * e.g. [e2, e4] represents a move from e2 to e4
 * [e7, e8, queen] represents a pawn promotion to queen from e7 to e8
 * 
 * @author Abhijeet Krishnan
 * @copyright (c)2022 Abhijeet Krishnan.
 * @license All rights reserved. Used with permission.
 */

:- ['piece_types.pl'].
:- ['squares.pl'].

/**
 * move(+Move:move, -From:sq_pred, -To:sq_pred, -Promo:list(piece_type)) is det
 *
 * Unpacks a move into its component parts represented as predicates.
 * A non-promotion move has the empty list as its Promo field output.
 *
 * @param Move
 * @param From A square/1 predicate representing the initial square
 * @param To A square/1 predicate representing the target square
 * @param Promo A list of 0 or 1 elements representing the promo piece type. If 0, it means the move was not a promotion.
 * If 1, the list contains a single piece_type/1 predicate representing the piece being promoted to.
 */
move([From, To], square(From), square(To), []).
move([From, To, Promo], square(From), square(To), piece_type(Promo)).

/**
 * is_promo(+Move:move) is det
 *
 * Check if a given move includes a promotion field
 *
 * @param Move
 */
is_promo([_, _, _|[]]).