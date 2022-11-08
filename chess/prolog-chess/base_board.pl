% The piece positions are represented by contents/2, which describe their piece (type + side) and location (square).
% e.g., a white rook on g4 would be represented as `contents(piece(rook, white), square(g4))`

:- ['colors.pl'].
:- ['piece_types.pl'].
:- ['squares.pl'].
:- ['pieces.pl'].
:- ['moves.pl'].
:- ['square_set.pl'].

% pieces(++BaseBoard, +Type, +Piece, -SquareSet)
% Gets pieces of a given type and color
% SquareSet is unified as a list of square/1 predicates for squares that contain the given piece
pieces([], _, _, []).
pieces([contents(piece(Type, Color), square(Square))|T], Type, Color, [square(Square)|T1]) :-
    pieces(T, Type, Color, T1).
pieces([_|T], Type, Color, SquareSet) :-
    pieces(T, Type, Color, SquareSet).

% piece_at(++BaseBoard, +At, -Piece)
% Gets piece at given location provided as a square/1 predicate
piece_at(BaseBoard, Piece, At) :-
    member(contents(Piece, At), BaseBoard).

% attacks(++BaseBoard, +Square, -SquareSet)
% Gets the set of attacked squares from the given square.
% There will be no attacks if the square is empty. Pinned pieces are still attacking other squares.
% Returns a set of squares (SquareSet i.e., list of square/1 predicates).
attacks(BaseBoard, Square, SquareSet) :-
    piece_at(BaseBoard, Square, piece(Type, Side)),
    attack_squares(Square, Type, Side, SquareSet).

remove_piece_at(BaseBoard, At, NewBaseBoard) :-
    delete(BaseBoard, contents(_, At), NewBaseBoard).

set_piece_at(BaseBoard, Piece, At, NewBaseBoard) :-
    append(BaseBoard, [contents(Piece, At)], NewBaseBoard).