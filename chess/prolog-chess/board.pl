% A chess game state in Prolog is represented by a list of predicates.
%
% The piece positions are represented by contents/2, which describe their piece (type + side) and location (square).
% The side whose turn it is to play is represented by turn/1
% Castling rights denoted by kingside_castle/2 and queenside_castle/2
% Full move count denoted by fullmove/1
% Half move clock denoted by halfmove_clock/1
% En passant square denoted by en_passant/1

:- ['colors.pl'].
:- ['piece_types.pl'].
:- ['squares.pl'].
:- ['pieces.pl'].
:- ['moves.pl'].
:- ['base_board.pl'].

outcome(checkmate).
outcome(stalemate).
outcome(insufficient_material).
outcome(seventyfile_move_rule).
outcome(fivefold_repetition).

% turn(++Board, -Side)
turn(Board, Side) :-
    member(turn(Side), Board),
    color(Side).

% kingside_castle(++Board, -Side)
kingside_castle(Board, Side) :-
    member(kingside_castle(Side), Board).

% queenside_castle(++Board, -Side)
queenside_castle(Board, Side) :-
    member(queenside_castle(Side), Pos).

% fullmove(++Board, -N)
fullmove(Board, N) :-
    member(fullmove(N), Board).

increment_fullmove(Board, NewBoard) :-
    turn(Board, Side),
    (
        Side =:= black ->
            fullmove(Board, N),
            delete(Board, fullmove(_), Board_1),
            NewN is N + 1,
            append(Board_1, [fullmove(NewN), NewBoard])
        ;
            NewBoard = Board
    ).

% halfmove_clock(++Board, -N)
halfmove_clock(Board, N) :-
    member(halfmove_clock(N), Board).

set_halfmove_clock(Board, NewN, NewBoard) :-
    delete(Board, halfmove_clock(_), Board_1),
    append(Board_1, [halfmove_clock(NewN), NewBoard]).

increment_halfmove_clock(Board, NewBoard) :-
    halfmove_clock(Board, N),
    NewN is N + 1,
    set_halfmove_clock(Board, NewN, NewBoard).

reset_halfmove_clock(Board, NewBoard) :-
    set_halfmove_clock(Board, 0, NewBoard).

% en_passant(++Board, -Square)
en_passant(Board, Square) :-
    member(en_passant(Square), Board),
    square(Square).

castling_str_to_rights('K', kingside_castle(white)).
castling_str_to_rights('Q', queenside_castle(white)).
castling_str_to_rights('k', kingside_castle(black)).
castling_str_to_rights('q', queenside_castle(black)).

castling_rights("-", []).
castling_rights(CastleRights, CastleRightsStr) :-
    string_chars(CastleRightsStr, CastleRightsList),
    maplist(castling_str_to_rights, CastleRightsList, CastleRights).

scan_row([], _, _, []).
scan_row([H1|T1], Row, Col, [H2|T2]) :-
    (
        char_type(H1, digit) ->
            atom_number(H1, Incr),
            NewCol is Col + Incr,
            H2 = [],
            scan_row(T1, Row, NewCol, T2)
        ;
            piece_from_char(H1, Piece),
            coords(Sq, Col, Row),
            NewCol is Col + 1,
            H2 = contents(Piece, square(Sq)),
            scan_row(T1, Row, NewCol, T2)
    ).

set_board_contents(PosStr, Board) :-
    split_string(PosStr, "/", "", [Row8, Row7, Row6, Row5, Row4, Row3, Row2, Row1]),
    string_chars(Row1, Row1List),
    string_chars(Row2, Row2List),
    string_chars(Row3, Row3List),
    string_chars(Row4, Row4List),
    string_chars(Row5, Row5List),
    string_chars(Row6, Row6List),
    string_chars(Row7, Row7List),
    string_chars(Row8, Row8List),
    scan_row(Row1List, 1, 1, Row1Preds),
    scan_row(Row2List, 2, 1, Row2Preds),
    scan_row(Row3List, 3, 1, Row3Preds),
    scan_row(Row4List, 4, 1, Row4Preds),
    scan_row(Row5List, 5, 1, Row5Preds),
    scan_row(Row6List, 6, 1, Row6Preds),
    scan_row(Row7List, 7, 1, Row7Preds),
    scan_row(Row8List, 8, 1, Row8Preds),
    flatten([Row1Preds, Row2Preds, Row3Preds, Row4Preds, Row5Preds, Row6Preds, Row7Preds, Row8Preds], Board).

en_passant_sq([], "-").
en_passant_sq(EnPassantPred, EnPassantStr) :-
    atom_string(EnPassantAtom, EnPassantStr),
    EnPassantPred = [en_passant(EnPassantAtom)].

set_board_fen(Fen, BaseBoard) :-
    split_string(Fen, " ", "", [PosStr, TurnStr, CastleRightsStr, EpStr, HmClkStr, FmNumStr]),
    set_board_contents(PosStr, PosPreds),
    from_str(TurnCol, TurnStr),
    castling_rights(CastleRightsPreds, CastleRightsStr),
    en_passant_sq(EpPred, EpStr),
    number_string(HalfmoveClock, HmClkStr),
    number_string(Fullmove, FmNumStr),
    flatten([PosPreds, turn(TurnCol), CastleRightsPreds, EpPred, halfmove_clock(HalfmoveClock), fullmove(Fullmove)], BaseBoard).

% a move is a capture if a piece of the opposing color lies on the square to which the move is being made
is_capture(Board, [From, To|_]) :-
    turn(Board, Side),
    other_color(Side, OpposingSide),
    piece_at(Board, To, piece(_, OpposingSide)).

% is_zeroing(++Board, +Move)
% a move is zeroing if it is a capture or a pawn move
is_zeroing(Board, [From, To|_]) :-
    piece_at(Board, From, pawn).
is_zeroing(Board, [From, To|_]) :-
    is_capture(Board, [From, To]).

update_castling_rights(Board, [e1, To|_], NewBoard) :-
    piece_at(Board, e1, piece(king, white)),
    delete(Board, kingside_castle(white), Board_1),
    delete(Board_1, queenside_castle(white), NewBoard).
update_castling_rights(Board, [e8, To|_], NewBoard) :-
    piece_at(Board, e8, piece(king, black)),
    delete(Board, kingside_castle(black), Board_1),
    delete(Board_1, queenside_castle(black), NewBoard).
update_castling_rights(Board, [a1, To|_], NewBoard) :-
    piece_at(Board, a1, piece(rook, white)),
    delete(Board_1, queenside_castle(white), NewBoard).
update_castling_rights(Board, [h1, To|_], NewBoard) :-
    piece_at(Board, h1, piece(rook, white)),
    delete(Board, kingside_castle(white), NewBoard).
update_castling_rights(Board, [a8, To|_], NewBoard) :-
    piece_at(Board, a8, piece(rook, black)),
    delete(Board_1, queenside_castle(black), NewBoard).
update_castling_rights(Board, [h8, To|_], NewBoard) :-
    piece_at(Board, h8, piece(rook, black)),
    delete(Board, kingside_castle(black), NewBoard).

% legal_move(++Board, +Move)
legal_move(Board, Move) :-
    fail.

% pseudo_legal_move(++Board, +Move)
pseudo_legal_move(Board, Move) :-
    fail.

make_move(Board, Move, NewBoard) :-
    increment_halfmove_clock(Board, Board_1),
    increment_fullmove(Board_1, Board_2),
    (
        is_zeroing(Board, Move) ->
            reset_halfmove_clock(Board_2, Board_3)
        ;
            Board_3 is Board_2
    ),

    [From, To|_] = Move,
    piece_at(Board, From, MovedPiece),
    ignore(piece_at(Board, To, CapturedPiece)),
    remove_piece_at(Board_3, From, Board_4),
    remove_piece_at(Board_4, To, Board_5),
    update_castling_rights(Board_5, Move, Board_6),
    fail.

ply(Board, Ply) :-
    fullmove(Board, FullMove),
    turn(Board, Side),
    (
        Side =:= black ->
            Ply is 2 * FullMove + 1
        ;
            Ply is 2 * FullMove
    ).

% Gets the pieces currently giving check
checkers(Board, Checkers) :-
    fail.

% Tests if the current side to move is in check
in_check(Board) :-
    fail.

% Probes if the given move would put the opponent in check. The move must be at least pseudo-legal.
gives_check(Board, Move) :-
    pseudo_legal_move(Board, Move),
    make_move(Board, Move, NewBoard),
    in_check(NewBoard).

outcome(Board, Outcome) :-
    outcome(Outcome),
    fail.

is_checkmate(Board) :-
    fail.

is_stalemate(Board) :-
    fail.

is_insufficient_material(Board) :-
    fail.

has_insufficient_material(Board, Color) :-
    fail.

is_seventyfive_moves(Board) :-
    fail.

is_fivefold_repetition(Board) :-
    fail.

