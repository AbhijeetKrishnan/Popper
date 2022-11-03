% A set of squares.

:- ['colors.pl'].
:- ['piece_types.pl'].
:- ['squares.pl'].
:- ['pieces.pl'].
:- ['moves.pl'].

pawn_attack_delta(white, -1, 1).
pawn_attack_delta(white, 1, 1).
pawn_attack_delta(black, -1, -1).
pawn_attack_delta(black, 1, -1).

knight_delta(-2, -1).
knight_delta(-2, 1).
knight_delta(-1, -2).
knight_delta(-1, 2).
knight_delta(1, -2).
knight_delta(1, 2).
knight_delta(2, -1).
knight_delta(2, 1).

king_delta(-1, -1).
king_delta(-1, 0).
king_delta(-1, 1).
king_delta(0, -1).
king_delta(0, 1).
king_delta(1, -1).
king_delta(1, 0).
king_delta(1, 1).

% down-left
dl_diag_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X - N,
    Y_a is Y - N,
    coords(AttackSquare, X_a, Y_a).

% up-left
ul_diag_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X + N,
    Y_a is Y - N,
    coords(AttackSquare, X_a, Y_a).

% down-right
dr_diag_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X - N,
    Y_a is Y + N,
    coords(AttackSquare, X_a, Y_a).

% up-right
ur_diag_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X + N,
    Y_a is Y + N,
    coords(AttackSquare, X_a, Y_a).

% down
d_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    Y_a is Y - N,
    coords(AttackSquare, X, Y_a).

% up
u_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    Y_a is Y + N,
    coords(AttackSquare, X, Y_a).

% left
l_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X - N,
    coords(AttackSquare, X_a, Y).

% right
r_attacks(Square, AttackSquare) :-
    coords(Square, X, Y),
    between(1, 7, N),
    X_a is X + N,
    coords(AttackSquare, X_a, Y).

attack_square_(Square, pawn, Side, AttackSquare) :-
    coords(Square, X, Y),
    pawn_attack_delta(Side, DelX, DelY),
    X_a is X + DelX,
    Y_a is Y + DelY,
    coords(AttackSquare, X_a, Y_a).
attack_square_(Square, knight, _, AttackSquare) :-
    coords(Square, X, Y),
    knight_delta(DelX, DelY),
    X_a is X + DelX,
    Y_a is Y + DelY,
    coords(AttackSquare, X_a, Y_a).
attack_square_(Square, king, _, AttackSquare) :-
    coords(Square, X, Y),
    king_delta(DelX, DelY),
    X_a is X + DelX,
    Y_a is Y + DelY,
    coords(AttackSquare, X_a, Y_a).
attack_square_(Square, rook, _, AttackSquare) :-
    u_attacks(Square, AttackSquare).
attack_square_(Square, rook, _, AttackSquare) :-
    d_attacks(Square, AttackSquare).
attack_square_(Square, rook, _, AttackSquare) :-
    l_attacks(Square, AttackSquare).
attack_square_(Square, rook, _, AttackSquare) :-
    r_attacks(Square, AttackSquare).
attack_square_(Square, bishop, _, AttackSquare) :-
    ul_diag_attacks(Square, AttackSquare).
attack_square_(Square, bishop, _, AttackSquare) :-
    dl_diag_attacks(Square, AttackSquare).
attack_square_(Square, bishop, _, AttackSquare) :-
    ur_diag_attacks(Square, AttackSquare).
attack_square_(Square, bishop, _, AttackSquare) :-
    dr_diag_attacks(Square, AttackSquare).
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

attack_squares(Square, Type, Side, SquareSet) :-
    findall(AttackSquare, attack_square_(Square, Type, Side, AttackSquare), SquareSet).
