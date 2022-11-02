% Represents a move from a square to a square and possibly the promotion piece type.
% Drops and null moves are NOT supported.
%
% A move is represented by a list of two or three elements
% The first element if the From square - the square the move is made from
% The second element is the To square - the square the move is made to
% The third (optional) element is the Promo piece - the piece to which the current piece (pawn) is being promoted

:- ['piece_types.pl'].
:- ['squares.pl'].

% is_promo(++Move)
is_promo([From, To, Promo|[]]).

% move(++Move, -From, -To[, -Promo])
move([From, To|[]], From, To) :-
    square(From),
    square(To).
move([From, To, Promo|[]], From, To, Promo) :-
    square(From),
    square(To),
    piece_type(Promo).