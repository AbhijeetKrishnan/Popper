% A piece with type and color.
% a piece is represented with the predicate piece/2.

:- ['colors.pl'].
:- ['piece_types.pl'].

piece_from_char('P', piece(pawn, white)).
piece_from_char('N', piece(knight, white)).
piece_from_char('B', piece(bishop, white)).
piece_from_char('R', piece(rook, white)).
piece_from_char('Q', piece(queen, white)).
piece_from_char('K', piece(king, white)).

piece_from_char('p', piece(pawn, black)).
piece_from_char('n', piece(knight, black)).
piece_from_char('b', piece(bishop, black)).
piece_from_char('r', piece(rook, black)).
piece_from_char('q', piece(queen, black)).
piece_from_char('k', piece(king, black)).

% piece(++Type, ++Color)
piece(Type, Color) :-
    piece_type(Type),
    color(Color).