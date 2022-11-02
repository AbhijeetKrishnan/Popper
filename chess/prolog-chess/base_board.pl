% The piece positions are represented by contents/2, which describe their piece (type + side) and location (square).

:- ['colors.pl'].
:- ['piece_types.pl'].
:- ['squares.pl'].
:- ['pieces.pl'].
:- ['moves.pl'].

pieces(BaseBoard, Type, Color, SquareSet) :-
    fail.

piece_at(BaseBoard, At, Piece) :-
    member(contents(Piece, At), BaseBoard).

attacks(BaseBoard, Square, SquareSet) :-
    fail.

remove_piece_at(BaseBoard) :-
    fail.

set_piece_at(BaseBoard, Piece) :-
    fail.

set_board_fen(Fen, BaseBoard) :-
    fail.