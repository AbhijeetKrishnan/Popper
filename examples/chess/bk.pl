legal_move(Side,Piece,Place,NewPlace,Pos1):-
    contents(Side,Piece,Place,Pos1),
    piece_move(Side,Piece,Place,NewPlace,Pos1),
    do_move(Side,Piece,Place,NewPlace,Pos1,Pos2),
    \+ in_check(Side,_,_,_,Pos2).

in_check(Side,KPlace,OPiece,OPlace,Pos):-
    contents(Side,king,KPlace,Pos),
    contents(OSide,OPiece,OPlace,Pos),
    other_side(Side,OSide),
    piece_move(OSide,OPiece,OPlace,KPlace,Pos).

check_mate(Side,Place,Pos):-
    contents(Side,king,Place,Pos),
    in_check(Side,Place,_,_,Pos),
    \+ legal_move(Side,king,Place,_,Pos).

make_move(Side,Piece,Place,NewPlace,Pos1,Pos2):-
    legal_move(Side,Piece,Place,NewPlace,Pos1),
    other_side(Side,OSide),
    \+ in_check(OSide,_,_,_,Pos1),
    do_move(Side,Piece,Place,NewPlace,Pos1,Pos2).

other_side(white,black).
other_side(black,white).

sliding_piece(Piece,Place,Pos):-
    contents(Side,Piece,Place,Pos),
    member(Piece,[queen,bishop,rook]).

do_move(Side,Piece,Place,NewPlace,Pos1,Pos2) :-
    current_state(State),
    create_new_state(Pos1,State,Pos2,NState),
    retract_if_there(contents(_,_,NewPlace,Pos2)),
    retract(contents(Side,Piece,Place),Pos2),
    asserta(contents(Side,Piece,NewPlace),Pos2),
    !,
    restore_if_redo(State).

current_state(State) :-
    description_pred(Descript),
    findall(Descript,State).

restore_state(State) :-
    description_pred(Descript),
    retractall(Descript),
    asserta_all(State).

restore_if_redo(_).
restore_if_redo(State) :-
    restore_state(State),
    !,
    fail.

create_new_state(Pos,State,NPos,NState) :-
    new_pos(NPos),
    replace(Pos,NPos,State,NState),
    asserta_all(NState).

feature(contents(_,_,square(_,_),_)).
feature(sliding_piece(_,square(_,_),_)).
feature(check_mate(_,square(_,_),_)).
feature(stale(_,_,square(_,_),_)).
feature(stale(_,_),_).
feature(legal_move(_,_,square(_,_),square(_,_),_)).
feature(in_check(_,square(_,_),_,square(_,_),_)).

description_pred(contents/4).
domain(side,[white,black]).
domain(piece,[pawn,knight,bishop,rook,queen,king]).
domain(place,[square(1,1),square(1,2),...,square(8,8)]).
type_arg(white,side) :- !.
type_arg(black,side) :- !.
type_arg(square(_,_),place) :- !.
type_arg(_,piece).

contents(black, king, square(5,7), pos1).
contents(black, rook, square(3,7), pos1).
contents(white, king, square(1,1), pos1).
contents(white, knight, square(6,4), pos1).

legal_move(white, king, square(1,1), square(2,1), pos1).
legal_move(white, king, square(1,1), square(2,2), pos1).
legal_move(white, king, square(1,1), square(1,2), pos1).
legal_move(white, knight, square(6,4), square(4,5), pos1).
legal_move(white, knight, square(6,4), square(8,5), pos1).
legal_move(white, knight, square(6,4), square(5,6), pos1).
legal_move(white, knight, square(6,4), square(7,6), pos1).
legal_move(white, knight, square(6,4), square(4,3), pos1).
legal_move(white, knight, square(6,4), square(8,3), pos1).
legal_move(white, knight, square(6,4), square(5,2), pos1).
legal_move(white, knight, square(6,4), square(7,2), pos1).