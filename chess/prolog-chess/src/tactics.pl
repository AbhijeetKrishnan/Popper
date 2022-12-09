:- module(tactics, [
    fork_2/2,
    fork/3,
    pin/4,
    discovered_check/3
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
    piece_at(Board, piece(_, Side), ForkerSquare), % TODO: this can't be used in Popper, piece_at needs to have all params exposed then
    findall(ForkedSquare, can_capture(Board, ForkerSquare, ForkedSquare), ForkedSquares), % TODO: this also can't be used, and needs to be exposed
    length(ForkedSquares, Len), % TODO: this must be exposed too
    Len >= 2. % TODO: this must be exposed too

fork_2(Board, Move) :-
    legal_move(Board, Move),
    move(Move, From, To, Promo),
    turn(Board, Side),
    piece_at(Board, Piece, From),
    valid_piece(Piece, _, Side),
    make_move(Board, [From, To], NewBoard),
    can_capture(NewBoard, To, ForkSquare1),
    can_capture(NewBoard, To, ForkSquare2),
    different(ForkSquare1, ForkSquare2).

% there is a pin on the board if a (sliding) piece (PinningPiece) attacks an opponent piece (PinnedPiece), which has another
% opponent piece 'behind' it
pin(Board, PinningPieceSq, PinnedPieceSq, BehindSq) :- % TODO: how to allow/learn tactics with varying rule heads like this?
    turn(Board, Side),
    piece_at(Board, piece(Type, Side), PinningPieceSq), % TODO: needs to be exposed as only params
    sliding(Type),
    can_capture(Board, PinningPieceSq, PinnedPieceSq),
    remove_piece_at(Board, PinnedPieceSq, NewBoard), % TODO: minor fix, but I think I wasn't including this earlier
    can_capture(NewBoard, PinningPieceSq, BehindSq),
    sq_between(PinningPieceSq, BehindSq, 1, PinnedPieceSq). % TODO: not sure this sq_between(..., 1/0, ...) is something that Popper will handle

% discovered check is a move that leads to a check on the opponent by a piece which is not the moved piece
discovered_check(Board, Move, CheckerSquare) :- % TODO: how to allow/learn tactics with varying rule heads like this?
    [From, _|_] = Move, % TODO: no exposed function
    make_move(Board, Move, NewBoard),
    turn(NewBoard, Side),
    in_check(NewBoard, Side, CheckerSquare),
    From \== CheckerSquare. % TODO: no exposed function

% battery
% a battery exists on the board when a sliding piece (rook, bishop only) occupies an empty file/diagonal
battery(Board, Batterer) :-
    fail. % TODO: implement