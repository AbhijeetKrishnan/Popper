:- module(tactics, [
    fork/2
]).

:- use_module(colors).
:- use_module(piece_types).
:- use_module(squares).
:- use_module(pieces).
:- use_module(moves).
:- use_module(base_board).
:- use_module(board).

% there is a fork on the board if a piece (of the side to play) attacks two (or more) opponent pieces simultaneously
fork(Board, ForkerSquare) :-
    turn(Board, Side),
    piece_at(Board, piece(_, Side), ForkerSquare), % TODO: this can't be used in Popper, piece_at needs to have all params exposed then
    findall(ForkedSquare, can_capture(Board, ForkerSquare, ForkedSquare), ForkedSquares), % TODO: this also can't be used, and needs to be exposed
    length(ForkedSquares, Len), % TODO: this must be exposed too
    Len >= 2. % TODO: this must be exposed too
