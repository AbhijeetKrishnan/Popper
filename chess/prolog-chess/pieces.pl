% A piece with type and color.
% a piece is represented with the predicate piece/2.

:- ['colors.pl'].
:- ['piece_types.pl'].

% piece(++Type, ++Color)
piece(Type, Color) :-
    piece_type(Type),
    color(Color).