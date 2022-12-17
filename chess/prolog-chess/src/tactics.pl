:- module(tactics, [
    fork_2/2,
    fork/3,
    pin/4,
    pin_2/2,
    discovered_check/3,
    discovered_check_2/2
]).

:- use_module(colors).
:- use_module(piece_types).
:- use_module(squares).
:- use_module(pieces).
:- use_module(moves).
:- use_module(square_set).
:- use_module(base_board).
:- use_module(board).
:- use_module(make_move).

% there is a fork on the board if a piece (of the side to play) attacks two (or more) opponent pieces simultaneously
fork(Board, ForkerSquare, ForkedSquares) :- % TODO: how to allow/learn tactics with varying rule heads like this?
    turn(Board, Side),
    piece_at(Board, piece(_, Side), ForkerSquare),
    findall(ForkedSquare, can_capture(Board, ForkerSquare, ForkedSquare), ForkedSquares),
    length(ForkedSquares, Len),
    Len >= 2.

% max_clauses(1).
% max_vars(8).
% max_body(6).
fork_2(Board, Move) :-
    legal_move(Board, Move),
    move(Move, _, To, _),
    make_move(Board, Move, NewBoard),
    can_capture(NewBoard, To, ForkSquare1),
    can_capture(NewBoard, To, ForkSquare2),
    different(ForkSquare1, ForkSquare2).

% there is a pin on the board if a (sliding) piece (PinningPiece) attacks an opponent piece (PinnedPiece), which has another
% opponent piece 'behind' it
pin(Board, PinningPieceSq, PinnedPieceSq, BehindSq) :- % TODO: how to allow/learn tactics with varying rule heads like this?
    turn(Board, Side),
    piece_at(Board, piece(Type, Side), PinningPieceSq),
    sliding(Type),
    can_capture(Board, PinningPieceSq, PinnedPieceSq),
    remove_piece_at(Board, PinnedPieceSq, NewBoard),
    can_capture(NewBoard, PinningPieceSq, BehindSq),
    sq_between(PinningPieceSq, BehindSq, 1, PinnedPieceSq).

% max_clauses(1).
% max_vars(10).
% max_body(4).
pin_2(Board, Move) :-
    legal_move(Board, Move),
    move(Move, _, PinningPieceSq, _),
    make_move(Board, Move, NewBoard),
    xrays(NewBoard, PinningPieceSq, _, _).

% discovered check is a move that leads to a check on the opponent by a piece which is not the moved piece
discovered_check(Board, Move, CheckerSquare) :- % TODO: how to allow/learn tactics with varying rule heads like this?
    [_, To|_] = Move,
    make_move(Board, Move, NewBoard),
    turn(NewBoard, Side),
    in_check(NewBoard, Side, CheckerSquare),
    To \== CheckerSquare.

discovered_check_2(Board, Move) :-
    legal_move(Board, Move), % move must be legal
    move(Move, _, To, _), % unpack move contents
    make_move(Board, Move, NewBoard), % simulate the move on the board
    turn(NewBoard, Side), % get the side to play
    in_check(NewBoard, Side, CheckerSquare), % the side to play must be in check - get the checking piece
    different(To, CheckerSquare). % the checking piece must not be the same as the piece that moved -> discovered check

% battery
% a battery exists on the board when a sliding piece (rook, bishop only) occupies an empty file/diagonal
battery(Board, Batterer) :-
    fail. % TODO: implement