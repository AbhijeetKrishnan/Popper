/** <module> A set of squares
 *
 * Defines operations involving finding and/or manipulating sets of squares.
 * A square set is defined as a list of square/1 predicates representing the squares in the set.
 * e.g., a square set of legal moves for the e4 pawn in the start position is [square(e3), square(e4)]
 *
 * @author Abhijeet Krishnan
 * @copyright (c)2022 Abhijeet Krishnan.
 * @license All rights reserved. Used with permission.
 */

:- ['colors.pl'].
:- ['piece_types.pl'].
:- ['squares.pl'].
:- ['pieces.pl'].
:- ['moves.pl'].

/**
 * pawn_attack_delta(+Side:color, +FileDelta:int, +RankDelta:int) is det
 *
 * Allowable movement deltas for pawns.
 *
 * @param Side
 * @param FileDelta
 * @param RankDelta
 */
pawn_attack_delta(white, -1, 1).
pawn_attack_delta(white, 1, 1).
pawn_attack_delta(black, -1, -1).
pawn_attack_delta(black, 1, -1).

/**
 * knight_delta(+FileDelta:int, +RankDelta:int) is det
 *
 * Allowable movement deltas for knights.
 *
 * @param FileDelta
 * @param RankDelta
 */
knight_delta(-2, -1).
knight_delta(-2, 1).
knight_delta(-1, -2).
knight_delta(-1, 2).
knight_delta(1, -2).
knight_delta(1, 2).
knight_delta(2, -1).
knight_delta(2, 1).

/**
 * king_delta(+FileDelta:int, +RankDelta:int) is det
 *
 * Allowable movement deltas for kings.
 *
 * @param FileDelta
 * @param RankDelta
 */
king_delta(-1, -1).
king_delta(-1, 0).
king_delta(-1, 1).
king_delta(0, -1).
king_delta(0, 1).
king_delta(1, -1).
king_delta(1, 0).
king_delta(1, 1).

/**
 * dl_diag_attacks(+Square:square, -AttackSquare:square) is nondet
 *
 * Returns a square attack-able by a diagonally sliding piece (e.g., bishop, queen) via down-left diagonal move.
 *
 * @param Square Initial square for piece
 * @param AttackSquare Square which the piece can attack via down-left diagonal move
 */
dl_diag_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X - N,
    Y_a is Y - N,
    coords(AttackSquare, X_a, Y_a).

/**
 * ul_diag_attacks(+Square:square, -AttackSquare:square) is nondet
 *
 * Returns a square attack-able by a diagonally sliding piece (e.g., bishop, queen) via up-left diagonal move.
 *
 * @param Square Initial square for piece
 * @param AttackSquare Square which the piece can attack via up-left diagonal move
 */
ul_diag_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X + N,
    Y_a is Y - N,
    coords(AttackSquare, X_a, Y_a).

/**
 * dr_diag_attacks(+Square:square, -AttackSquare:square) is nondet
 *
 * Returns a square attack-able by a diagonally sliding piece (e.g., bishop, queen) via down-right diagonal move.
 *
 * @param Square Initial square for piece
 * @param AttackSquare Square which the piece can attack via down-right diagonal move
 */
dr_diag_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X - N,
    Y_a is Y + N,
    coords(AttackSquare, X_a, Y_a).

/**
 * ur_diag_attacks(+Square:square, -AttackSquare:square) is nondet
 *
 * Returns a square attack-able by a diagonally sliding piece (e.g., bishop, queen) via up-right diagonal move.
 *
 * @param Square Initial square for piece
 * @param AttackSquare Square which the piece can attack via up-right diagonal move
 */
ur_diag_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X + N,
    Y_a is Y + N,
    coords(AttackSquare, X_a, Y_a).

/**
 * d_attacks(+Square:square, -AttackSquare:square) is nondet
 *
 * Returns a square attack-able by a linearly sliding piece (e.g., rook, queen) via down move.
 *
 * @param Square Initial square for piece
 * @param AttackSquare Square which the piece can attack via down move
 */
d_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    Y_a is Y - N,
    coords(AttackSquare, X, Y_a).

/**
 * u_attacks(+Square:square, -AttackSquare:square) is nondet
 *
 * Returns a square attack-able by a linearly sliding piece (e.g., rook, queen) via up move.
 *
 * @param Square Initial square for piece
 * @param AttackSquare Square which the piece can attack via up move
 */
u_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    Y_a is Y + N,
    coords(AttackSquare, X, Y_a).

/**
 * l_attacks(+Square:square, -AttackSquare:square) is nondet
 *
 * Returns a square attack-able by a linearly sliding piece (e.g., rook, queen) via left move.
 *
 * @param Square Initial square for piece
 * @param AttackSquare Square which the piece can attack via left move
 */
l_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X - N,
    coords(AttackSquare, X_a, Y).

/**
 * r_attacks(+Square:square, -AttackSquare:square) is nondet
 *
 * Returns a square attack-able by a linearly sliding piece (e.g., rook, queen) via right move.
 *
 * @param Square Initial square for piece
 * @param AttackSquare Square which the piece can attack via right move
 */
r_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X + N,
    coords(AttackSquare, X_a, Y).

/**
 * attack_square_(+Square:square, +PieceType:p_type, +Side:color, -AttackSquare:square) is nondet
 *
 * Defines possible squares that a piece could attack.
 *
 * @param Square
 * @param PieceType
 * @param Side
 * @param AttackSquare
 */
% pawn
attack_square_(Square, pawn, SideAtom, AttackSquare) :-
    coords(Square, X, Y),
    pawn_attack_delta(Side, DelX, DelY),
    X_a is X + DelX,
    Y_a is Y + DelY,
    coords(AttackSquare, X_a, Y_a).
% knight
attack_square_(Square, knight, _, AttackSquare) :-
    coords(Square, X, Y),
    knight_delta(DelX, DelY),
    X_a is X + DelX,
    Y_a is Y + DelY,
    coords(AttackSquare, X_a, Y_a).
% king
attack_square_(Square, king, _, AttackSquare) :-
    coords(Square, X, Y),
    king_delta(DelX, DelY),
    X_a is X + DelX,
    Y_a is Y + DelY,
    coords(AttackSquare, X_a, Y_a).
% rook
attack_square_(Square, rook, _, AttackSquare) :-
    u_attacks(Square, AttackSquare).
attack_square_(Square, rook, _, AttackSquare) :-
    d_attacks(Square, AttackSquare).
attack_square_(Square, rook, _, AttackSquare) :-
    l_attacks(Square, AttackSquare).
attack_square_(Square, rook, _, AttackSquare) :-
    r_attacks(Square, AttackSquare).
% bishop
attack_square_(Square, bishop, _, AttackSquare) :-
    ul_diag_attacks(Square, AttackSquare).
attack_square_(Square, bishop, _, AttackSquare) :-
    dl_diag_attacks(Square, AttackSquare).
attack_square_(Square, bishop, _, AttackSquare) :-
    ur_diag_attacks(Square, AttackSquare).
attack_square_(Square, bishop, _, AttackSquare) :-
    dr_diag_attacks(Square, AttackSquare).
% queen
attack_square_(Square, queen, _, AttackSquare) :-
    u_attacks(Square, AttackSquare).
attack_square_(Square, queen, _, AttackSquare) :-
    d_attacks(Square, AttackSquare).
attack_square_(Square, queen, _, AttackSquare) :-
    l_attacks(Square, AttackSquare).
attack_square_(Square, queen, _, AttackSquare) :-
    r_attacks(Square, AttackSquare).
attack_square_(Square, queen, _, AttackSquare) :-
    ul_diag_attacks(Square, AttackSquare).
attack_square_(Square, queen, _, AttackSquare) :-
    dl_diag_attacks(Square, AttackSquare).
attack_square_(Square, queen, _, AttackSquare) :-
    ur_diag_attacks(Square, AttackSquare).
attack_square_(Square, queen, _, AttackSquare) :-
    dr_diag_attacks(Square, AttackSquare).

/**
 * attack_squares(+Square:square, +PieceType:p_type, +Side:color, -SquareSet:sqset) is nondet
 *
 * Find all possible attack squares for a piece.
 *
 * @param Square
 * @param PieceType
 * @param Side
 * @param SquareSet A square set representing all squares that the input piece attacks.
 */
attack_squares(Square, PieceType, Side, SquareSet) :-
    findall(AttackSquare, attack_square_(Square, PieceType, Side, AttackSquare), SquareSet).
