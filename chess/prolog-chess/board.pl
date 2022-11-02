% A chess game state in Prolog is represented by a list of predicates.
%
% The piece positions are represented by contents/2, which describe their piece (type + side) and location (square).
% The side whose turn it is to play is represented by turn/1
% Castling rights denoted by kingside_castle/2 and queenside_castle/2
% Full move count denoted by fullmove/1
% Half move clock denoted by halfmove_clock/1
% En passant square denoted by en_passant/1

:- ['colors.pl'].
:- ['piece_types.pl'].
:- ['squares.pl'].
:- ['pieces.pl'].
:- ['moves.pl'].

outcome(checkmate).
outcome(stalemate).
outcome(insufficient_material).
outcome(seventyfile_move_rule).
outcome(fivefold_repetition).

% turn(++Board, -Side)
turn(Board, Side) :-
    member(turn(Side), Board),
    color(Side).

% kingside_castle(++Board, -Side)
kingside_castle(Board, Side) :-
    member(kingside_castle(Side), Board).

% queenside_castle(++Board, -Side)
queenside_castle(Board, Side) :-
    member(queenside_castle(Side), Pos).

% fullmove(++Board, -N)
fullmove(Board, N) :-
    member(fullmove(N), Board).

% halfmove_clock(++Board, -N)
halfmove_clock(Board, N) :-
    member(halfmove_clock(N), Board).

% en_passant(++Board, -Square)
en_passant(Board, Square) :-
    member(en_passant(Square), Board),
    square(Square).

% legal_move(++Board, +Move)
legal_move(Board, Move) :-
    fail.

% pseudo_legal_move(++Board, +Move)
pseudo_legal_move(Board, Move) :-
    fail.

make_move(Board, Move, NewBoard) :-
    fail.

ply(Board, Ply) :-
    fullmove(Board, FullMove),
    turn(Board, Side),
    (
        Side =:= black ->
            Ply is 2 * FullMove + 1
        ;
            Ply is 2 * FullMove
    ).

% Gets the pieces currently giving check
checkers(Board, Checkers) :-
    fail.

% Tests if the current side to move is in check
in_check(Board) :-
    fail.

% Probes if the given move would put the opponent in check. The move must be at least pseudo-legal.
gives_check(Board, Move) :-
    pseudo_legal_move(Board, Move),
    make_move(Board, Move, NewBoard),
    in_check(NewBoard).

outcome(Board, Outcome) :-
    outcome(Outcome),
    fail.

is_checkmate(Board) :-
    fail.

is_stalemate(Board) :-
    fail.

is_insufficient_material(Board) :-
    fail.

has_insufficient_material(Board, Color) :-
    fail.

is_seventyfive_moves(Board) :-
    fail.

is_fivefold_repetition(Board) :-
    fail.

