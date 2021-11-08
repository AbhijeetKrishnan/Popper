cons(A,B,C):-
    append([A],B,C).
tail([_|T],T).
head([H|_],H).
empty([]).

element([X|_],X):-!.
element([_|T],X):-
    element(T,X).

is_list([]).
is_list([_|_]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

square(1,1). square(1,2). square(1,3). square(1,4). square(1,5). square(1,6). square(1,7). square(1,8).
square(2,1). square(2,2). square(2,3). square(2,4). square(2,5). square(2,6). square(2,7). square(2,8).
square(3,1). square(3,2). square(3,3). square(3,4). square(3,5). square(3,6). square(3,7). square(3,8).
square(4,1). square(4,2). square(4,3). square(4,4). square(4,5). square(4,6). square(4,7). square(4,8).
square(5,1). square(5,2). square(5,3). square(5,4). square(5,5). square(5,6). square(5,7). square(5,8).
square(6,1). square(6,2). square(6,3). square(6,4). square(6,5). square(6,6). square(6,7). square(6,8).
square(7,1). square(7,2). square(7,3). square(7,4). square(7,5). square(7,6). square(7,7). square(7,8).
square(8,1). square(8,2). square(8,3). square(8,4). square(8,5). square(8,6). square(8,7). square(8,8).

side(white).
side(black).

piece(Piece) :-
    member(Piece, [pawn, knight, bishop, rook, queen, king]).

contents(Side,Piece,square(X,Y)) :-
    side(Side),
    piece(Piece),
    square(X,Y).

move(Side,Piece,square(X,Y),square(NewX,NewY)) :-
    side(Side),
    piece(Piece),
    square(X,Y),
    square(NewX,NewY).

% TODO: design a "state" property

% legal move is one where piece of move color exists at move location
% TODO: turn this into an actual legal_move property calculator?
% if I have this working correctly, I don't need to pass in all the legal moves in the target relation
legal_move(Side,Piece,square(X,Y),square(NewX,NewY)) :-
    move(Side,Piece,square(X,Y),square(NewX,NewY)),
    contents(Side,Piece,square(X,Y)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%