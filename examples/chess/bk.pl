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

sameRow(X1,Y1,X2,Y2) :-
    square(X1,Y1),
    square(X2,Y2),
    X1 == X2.

sameCol(X1,Y1,X2,Y2) :-
    square(X1,Y1),
    square(X2,Y2),
    Y1 == Y2.

side(white).
side(black).
other_side(white,black).
other_side(black,white).

piece(Piece) :-
    member(Piece, [pawn, knight, bishop, rook, queen, king]).

sliding_piece(Piece) :-
    member(Piece, [bishop, rook, queen]).

contents(Side,Piece,X,Y) :-
    side(Side),
    piece(Piece),
    square(X,Y).

move(FromX,FromY,ToX,ToY) :-
    square(FromX,FromY),
    square(ToX,ToY).

can_move(Piece, FromX, FromY, ToX, ToY) :-
    piece(Piece),
    square(FromX, FromY),
    square(ToX, ToY),
    DelX is ToX - FromX,
    DelY is ToY - FromY,
    allowed_del(Piece, DelX, DelY).

allowed_del(knight, -1, 2).
allowed_del(knight, 1, 2).
allowed_del(knight, -2, 1).
allowed_del(knight, 2, 1).
allowed_del(knight, -2, -1).
allowed_del(knight, 2, -1).
allowed_del(knight, -1, -2).
allowed_del(knight, 1, -2).

allowed_del(king, -1, 0).
allowed_del(king, -1, 1).
allowed_del(king, 0, 1).
allowed_del(king, 1, 1).
allowed_del(king, 1, 0).
allowed_del(king, 1, -1).
allowed_del(king, 0, -1).
allowed_del(king, -1, -1).

allowed_del(rook, 0, 1). allowed_del(rook, 0, -1).
allowed_del(rook, 0, 2). allowed_del(rook, 0, -2).
allowed_del(rook, 0, 3). allowed_del(rook, 0, -3).
allowed_del(rook, 0, 4). allowed_del(rook, 0, -4).
allowed_del(rook, 0, 5). allowed_del(rook, 0, -5).
allowed_del(rook, 0, 6). allowed_del(rook, 0, -6).
allowed_del(rook, 0, 7). allowed_del(rook, 0, -7).

allowed_del(rook, 1, 0). allowed_del(rook, -1, 0).
allowed_del(rook, 2, 0). allowed_del(rook, -2, 0).
allowed_del(rook, 3, 0). allowed_del(rook, -3, 0).
allowed_del(rook, 4, 0). allowed_del(rook, -4, 0).
allowed_del(rook, 5, 0). allowed_del(rook, -5, 0).
allowed_del(rook, 6, 0). allowed_del(rook, -6, 0).
allowed_del(rook, 7, 0). allowed_del(rook, -7, 0).

allowed_del(queen, -1, 1). allowed_del(queen, 0, 1). allowed_del(queen, 1, 1).
allowed_del(queen, -2, 2). allowed_del(queen, 0, 2). allowed_del(queen, 2, 2).
allowed_del(queen, -3, 3). allowed_del(queen, 0, 3). allowed_del(queen, 3, 3).
allowed_del(queen, -4, 4). allowed_del(queen, 0, 4). allowed_del(queen, 4, 4).
allowed_del(queen, -5, 5). allowed_del(queen, 0, 5). allowed_del(queen, 5, 5).
allowed_del(queen, -6, 6). allowed_del(queen, 0, 6). allowed_del(queen, 6, 6).
allowed_del(queen, -7, 7). allowed_del(queen, 0, 7). allowed_del(queen, 7, 7).

allowed_del(queen, -1, 0).                           allowed_del(queen, 1, 0).  
allowed_del(queen, -2, 0).                           allowed_del(queen, 2, 0).  
allowed_del(queen, -3, 0).                           allowed_del(queen, 3, 0).  
allowed_del(queen, -4, 0).                           allowed_del(queen, 4, 0).  
allowed_del(queen, -5, 0).                           allowed_del(queen, 5, 0).  
allowed_del(queen, -6, 0).                           allowed_del(queen, 6, 0).  
allowed_del(queen, -7, 0).                           allowed_del(queen, 7, 0).  

allowed_del(queen, -1, -1). allowed_del(queen, 0, -1). allowed_del(queen, 1, -1).
allowed_del(queen, -2, -2). allowed_del(queen, 0, -2). allowed_del(queen, 2, -2).
allowed_del(queen, -3, -3). allowed_del(queen, 0, -3). allowed_del(queen, 3, -3).
allowed_del(queen, -4, -4). allowed_del(queen, 0, -4). allowed_del(queen, 4, -4).
allowed_del(queen, -5, -5). allowed_del(queen, 0, -5). allowed_del(queen, 5, -5).
allowed_del(queen, -6, -6). allowed_del(queen, 0, -6). allowed_del(queen, 6, -6).
allowed_del(queen, -7, -7). allowed_del(queen, 0, -7). allowed_del(queen, 7, -7).

attacks(FromX,FromY,ToX,ToY,Pos) :-
    member(contents(Side,Piece,FromX,FromY), Pos),
    member(contents(OtherSide,OtherPiece,ToX,ToY), Pos),
    other_side(Side, OtherSide),
    piece(Piece),
    piece(OtherPiece),
    can_move(Piece, FromX, FromY, ToX, ToY).

different_pos(X1, Y1, X2, Y2) :-
    square(X1, Y1),
    square(X2, Y2),
    ( 
        X1 =\= X2 -> true ;
        Y1 =\= Y2 -> true ;
        false
    ).

pieceAt(X, Y, Pos, Side, Piece) :-
    member(contents(Side, Piece, X, Y), Pos).

fork(Pos, FromX, FromY, ToX, ToY) :-
    make_move(FromX, FromY, ToX, ToY, Pos, NewPos),
    attacks(ToX, ToY, X1, Y1, NewPos),
    attacks(ToX, ToY, X2, Y2, NewPos),
    different_pos(X1, Y1, X2, Y2).

behind(FrontX, FrontY, MiddleX, MiddleY, BackX, BackY, Pos) :-
    attacks(FrontX, FrontY, MiddleX, MiddleY, Pos),
    attacks(FrontX, FrontY, BackX, BackY, Pos),
    pieceAt(FrontX, FrontY, Pos, _, Piece),
    sliding_piece(Piece).

pin(Pos, FromX, FromY, ToX, ToY) :-
    make_move(FromX, FromY, ToX, ToY, Pos, NewPos),
    behind(ToX, ToY, MiddleX, MiddleY, BackX, BackY, NewPos),
    pieceAt(ToX, ToY, NewPos, SameSide, _),
    pieceAt(MiddleX, MiddleY, NewPos, OppSide, _),
    pieceAt(BackX, BackY, NewPos, OppSide, _),
    other_side(SameSide, OppSide).

% TODO: design a "state" property

% legal move is one where piece of move color exists at move location
% TODO: turn this into an actual legal_move property calculator?
% if I have this working correctly, I don't need to pass in all the legal moves in the target relation
legal_move(FromX,FromY,ToX,ToY,Pos) :-
    member(contents(_,Piece,FromX,FromY),Pos), % piece to be moved exists
    can_move(Piece,FromX,FromY,ToX,ToY). % move for the piece is theoretically permitted (if board was empty)
    
make_move(FromX,FromY,ToX,ToY,Pos, NewPos) :-
    legal_move(FromX,FromY,ToX,ToY,Pos),
    member(contents(Side,Piece,FromX,FromY),Pos),
    delete(Pos, contents(Side,Piece,FromX,FromY), TmpPos),
    append(TmpPos, [contents(Side, Piece, ToX, ToY)], NewPos).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%