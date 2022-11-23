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
 * pawn_single_move_(+Side:color, +FromFile:int, +FromRank:int, -ToFile:int, -ToRank:int) is det
 *
 * Helper rule to define a pawn single move from any position.
 *
 * @param Side
 * @param FromFile
 * @param FromRank
 * @param ToFile
 * @param ToRank
 */
pawn_single_move_(Side, FromFile, FromRank, FromFile, ToRank) :-
    ToRank is FromRank + 1.

/**
 * pawn_single_move(+Side:color, +From:square, -To:square) is det
 *
 * Defines a pawn single move from a position on the board.
 *
 * @param Side
 * @param From
 * @param To
 */
pawn_single_move(Side, From, To) :-
    coords(From, FromFile, FromRank),
    pawn_single_move_(Side, FromFile, FromRank, ToFile, ToRank),
    coords(To, ToFile, ToRank).

/**
 * pawn_double_move_(+Side:color, +FromFile:int, +FromRank:int, -MiddleFile:int, -MiddleRank:int, -ToFile:int, -ToRank:int) is det
 *
 * Helper rule to define a pawn double move from its initial position.
 *
 * @param Side
 * @param FromFile
 * @param FromRank
 * @param MiddleFile
 * @param MiddleRank
 * @param ToFile
 * @param ToRank
 */
pawn_double_move_(white, FromFile, 2, FromFile, 3, FromFile, 4).
pawn_double_move_(black, FromFile, 7, FromFile, 6, FromFile, 5).

/**
 * pawn_double_move(+Side:color, +From:square, -Middle:square, -To:square) is det
 *
 * Defines a pawn double move from its initial position.
 *
 * @param Side
 * @param From
 * @param Middle
 * @param To
 */
pawn_double_move(Side, From, Middle, To) :-
    coords(From, FromFile, FromRank),
    pawn_double_move_(Side, FromFile, FromRank, MiddleFile, MiddleRank, ToFile, ToRank),
    coords(Middle, MiddleFile, MiddleRank),
    coords(To, ToFile, ToRank).

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
 * attack_square(+Square:square, +PieceType:p_type, +Side:color, -AttackSquare:square) is nondet
 *
 * Defines possible squares that a piece could attack.
 *
 * @param Square
 * @param PieceType
 * @param Side
 * @param AttackSquare
 */
% pawn
attack_square(Square, pawn, SideAtom, AttackSquare) :-
    coords(Square, X, Y),
    pawn_attack_delta(Side, DelX, DelY),
    X_a is X + DelX,
    Y_a is Y + DelY,
    coords(AttackSquare, X_a, Y_a).
% knight
attack_square(Square, knight, _, AttackSquare) :-
    coords(Square, X, Y),
    knight_delta(DelX, DelY),
    X_a is X + DelX,
    Y_a is Y + DelY,
    coords(AttackSquare, X_a, Y_a).
% king
attack_square(Square, king, _, AttackSquare) :-
    coords(Square, X, Y),
    king_delta(DelX, DelY),
    X_a is X + DelX,
    Y_a is Y + DelY,
    coords(AttackSquare, X_a, Y_a).
% rook
attack_square(Square, rook, _, AttackSquare) :-
    u_attacks(Square, AttackSquare).
attack_square(Square, rook, _, AttackSquare) :-
    d_attacks(Square, AttackSquare).
attack_square(Square, rook, _, AttackSquare) :-
    l_attacks(Square, AttackSquare).
attack_square(Square, rook, _, AttackSquare) :-
    r_attacks(Square, AttackSquare).
% bishop
attack_square(Square, bishop, _, AttackSquare) :-
    ul_diag_attacks(Square, AttackSquare).
attack_square(Square, bishop, _, AttackSquare) :-
    dl_diag_attacks(Square, AttackSquare).
attack_square(Square, bishop, _, AttackSquare) :-
    ur_diag_attacks(Square, AttackSquare).
attack_square(Square, bishop, _, AttackSquare) :-
    dr_diag_attacks(Square, AttackSquare).
% queen
attack_square(Square, queen, _, AttackSquare) :-
    u_attacks(Square, AttackSquare).
attack_square(Square, queen, _, AttackSquare) :-
    d_attacks(Square, AttackSquare).
attack_square(Square, queen, _, AttackSquare) :-
    l_attacks(Square, AttackSquare).
attack_square(Square, queen, _, AttackSquare) :-
    r_attacks(Square, AttackSquare).
attack_square(Square, queen, _, AttackSquare) :-
    ul_diag_attacks(Square, AttackSquare).
attack_square(Square, queen, _, AttackSquare) :-
    dl_diag_attacks(Square, AttackSquare).
attack_square(Square, queen, _, AttackSquare) :-
    ur_diag_attacks(Square, AttackSquare).
attack_square(Square, queen, _, AttackSquare) :-
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
    findall(AttackSquare, attack_square(Square, PieceType, Side, AttackSquare), SquareSet).

/**
 * between_(+FileA:int, +RankA:int, +FileB:int, +RankB:int, +DelFile:int, +DelRank:int, +SignFile:int, +SignRank:int, -FileBet:int, -RankBet:int) is det
 *
 * Helper rule to find squares between two given squares.
 *
 * @param FileA
 * @param RankA
 * @param FileB
 * @param RankB
 * @param DelFile DelFile = abs(FileB - FileA)
 * @param DelRank DelRank = abs(RankB - RankA)
 * @param SignFile sign(DelFile)
 * @param SignRank sign(DelRank)
 * @param FileBet
 * @param RankBet
 */
between_(FileA, RankA, FileA, RankB, 0, N, 0, _, Inclusive, FileA, RankBet) :-
    LeftLimit is min(RankA, RankB) + 1,
    RightLimit is max(RankA, RankB) - Inclusive,
    between(LeftLimit, RightLimit, RankBet).
between_(FileA, RankA, FileB, RankA, N, 0, _, 0, Inclusive, FileBet, RankA) :-
    BotLimit is min(FileA, FileB) + 1,
    TopLimit is max(FileA, FileB) - Inclusive,
    between(BotLimit, TopLimit, FileBet).
between_(FileA, RankA, FileB, RankB, N, N, 1, 1, Inclusive, FileBet, RankBet) :-
    M is N - Inclusive,
    between(1, M, T),
    FileBet is FileA + T,
    RankBet is RankA + T.
between_(FileA, RankA, FileB, RankB, N, N, -1, -1, Inclusive, FileBet, RankBet) :-
    M is N - Inclusive,
    between(1, M, T),
    FileBet is FileA - T,
    RankBet is RankA - T.
between_(FileA, RankA, FileB, RankB, N, N, 1, -1, Inclusive, FileBet, RankBet) :-
    M is N - Inclusive,
    between(1, M, T),
    FileBet is FileA - T,
    RankBet is RankA + T.
between_(FileA, RankA, FileB, RankB, N, N, -1, 1, Inclusive, FileBet, RankBet) :-
    M is N - Inclusive,
    between(1, M, T),
    FileBet is FileA + T,
    RankBet is RankA - T.

/**
 * sq_between(+A:square, +B:square, +Inclusive:int, +Bet:square) is det
 *
 * Describes a square that lies on the straight line path between squares A and B.
 * If A and B are not on a straight line, no square lies in between them.
 *
 * @param A
 * @param B
 * @param Inclusive 0 for (From, To], 1 for (From, To)
 * @param Bet
 */
sq_between(A, B, Inclusive, Bet) :-
    coords(A, FileA, RankA),
    coords(B, FileB, RankB),
    DelFile is FileB - FileA,
    DelRank is RankB - RankA,
    SignFile is sign(DelFile),
    SignRank is sign(DelRank),
    MagFile is abs(DelFile),
    MagRank is abs(DelRank),
    between_(FileA, RankA, FileB, RankB, MagFile, MagRank, SignFile, SignRank, Inclusive, FileBet, RankBet),
    coords(Bet, FileBet, RankBet).