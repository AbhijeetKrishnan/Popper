/** <module> Defines squares in chess
 *
 *  This module defines predicates representing a chess position.
 *
 *  @author Abhijeet Krishnan
 *  @copyright (c)2022 Abhijeet Krishnan.
 *  @license All rights reserved. Used with permission.
 */

/**
 * coords(-Square:square, -File:int, -Rank:int) is semidet
 * 
 * Relates the chess notation of a square (e.g., e1, g4 etc.) to its file and rank indices.
 *
 * @param Square An atom representing a chess square (e.g., e1, g4 etc.)
 * @param File The index of the file (column) on which the square lies. Must be in [1, 8].
 * @param Rank The index of the rank (row) on which the square lies. Must be in [1, 8].
 */
coords(a1, 1, 1). coords(a2, 1, 2). coords(a3, 1, 3). coords(a4, 1, 4). coords(a5, 1, 5). coords(a6, 1, 6). coords(a7, 1, 7). coords(a8, 1, 8).
coords(b1, 2, 1). coords(b2, 2, 2). coords(b3, 2, 3). coords(b4, 2, 4). coords(b5, 2, 5). coords(b6, 2, 6). coords(b7, 2, 7). coords(b8, 2, 8).
coords(c1, 3, 1). coords(c2, 3, 2). coords(c3, 3, 3). coords(c4, 3, 4). coords(c5, 3, 5). coords(c6, 3, 6). coords(c7, 3, 7). coords(c8, 3, 8).
coords(d1, 4, 1). coords(d2, 4, 2). coords(d3, 4, 3). coords(d4, 4, 4). coords(d5, 4, 5). coords(d6, 4, 6). coords(d7, 4, 7). coords(d8, 4, 8).
coords(e1, 5, 1). coords(e2, 5, 2). coords(e3, 5, 3). coords(e4, 5, 4). coords(e5, 5, 5). coords(e6, 5, 6). coords(e7, 5, 7). coords(e8, 5, 8).
coords(f1, 6, 1). coords(f2, 6, 2). coords(f3, 6, 3). coords(f4, 6, 4). coords(f5, 6, 5). coords(f6, 6, 6). coords(f7, 6, 7). coords(f8, 6, 8).
coords(g1, 7, 1). coords(g2, 7, 2). coords(g3, 7, 3). coords(g4, 7, 4). coords(g5, 7, 5). coords(g6, 7, 6). coords(g7, 7, 7). coords(g8, 7, 8).
coords(h1, 8, 1). coords(h2, 8, 2). coords(h3, 8, 3). coords(h4, 8, 4). coords(h5, 8, 5). coords(h6, 8, 6). coords(h7, 8, 7). coords(h8, 8, 8).

/**
 * square(-Square:square) is nondet
 * 
 * Defines all possible squares in chess.
 *
 * @param Square An atom representing a chess square (e.g., e1, g4 etc.)
 */
square(a1). square(a2). square(a3). square(a4). square(a5). square(a6). square(a7). square(a8).
square(b1). square(b2). square(b3). square(b4). square(b5). square(b6). square(b7). square(b8).
square(c1). square(c2). square(c3). square(c4). square(c5). square(c6). square(c7). square(c8).
square(d1). square(d2). square(d3). square(d4). square(d5). square(d6). square(d7). square(d8).
square(e1). square(e2). square(e3). square(e4). square(e5). square(e6). square(e7). square(e8).
square(f1). square(f2). square(f3). square(f4). square(f5). square(f6). square(f7). square(f8).
square(g1). square(g2). square(g3). square(g4). square(g5). square(g6). square(g7). square(g8).
square(h1). square(h2). square(h3). square(h4). square(h5). square(h6). square(h7). square(h8).

/**
 * distance(+A:square, +B:square, -Dist:int) is det
 *
 * Gets the Manhattan distance (i.e., the number of king steps) from square A to B.
 *
 * @param A Square representing start point
 * @param B Square representing end point
 * @param Dist Manhattan distance between squares A and B
 */
distance(A, B, Dist) :-
    coords(A, X1, Y1),
    coords(B, X2, Y2),
    Dist is abs(X2 - X1) + abs(Y2 - Y1).

% Mirrors the square vertically.
% mirror(+Square, -Mirror)

/**
 * mirror(+Square:square, -Mirror:square) is det
 *
 * Mirrors the input square vertically.
 *
 * @param Square
 * @param Mirror
 */
mirror(Square, Mirror):-
    coords(Square, File, Rank),
    MirrorRank is 9 - Rank,
    coords(Mirror, File, MirrorRank).

/**
 * promo_rank(+Side:color, -Rank:int) is det
 *
 * Returns the rank at which the input side can make a promo with a subsequent single pawn move.
 *
 * @param Side
 * @param Rank
 */
promo_rank(white, 7).
promo_rank(black, 2).

/**
 * backrank(+Side:color, -Rank:int) is det
 *
 * Returns the back rank for the input side.
 *
 * @param Side
 * @param Rank
 */
backrank(white, 1).
backrank(black, 8).