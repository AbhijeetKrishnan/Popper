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
    member(queenside_castle(Side), Board).

% fullmove(++Board, -N)
fullmove(Board, N) :-
    member(fullmove(N), Board).

increment_fullmove(Board, NewBoard) :-
    turn(Board, Side),
    (
        Side = black ->
            fullmove(Board, N),
            delete(Board, fullmove(_), Board_1),
            NewN is N + 1,
            append(Board_1, [fullmove(NewN)], NewBoard)
        ;
            NewBoard = Board
    ).

% halfmove_clock(++Board, -N)
halfmove_clock(Board, N) :-
    member(halfmove_clock(N), Board).

set_halfmove_clock(Board, NewN, NewBoard) :-
    delete(Board, halfmove_clock(_), Board_1),
    NewBoard = [halfmove_clock(NewN)|Board_1].

increment_halfmove_clock(Board, NewBoard) :-
    halfmove_clock(Board, N),
    NewN is N + 1,
    set_halfmove_clock(Board, NewN, NewBoard).

reset_halfmove_clock(Board, NewBoard) :-
    set_halfmove_clock(Board, 0, NewBoard).

% en_passant(++Board, -Square)
en_passant(Board, square(Square)) :-
    member(en_passant(Square), Board).

castling_str_to_rights('K', kingside_castle(white)).
castling_str_to_rights('Q', queenside_castle(white)).
castling_str_to_rights('k', kingside_castle(black)).
castling_str_to_rights('q', queenside_castle(black)).

castling_rights([], "-").
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
is_capture(Board, [_, To|_]) :-
    turn(Board, Side),
    other_color(Side, OpposingSide),
    piece_at(Board, To, piece(_, OpposingSide)).

% is_zeroing(++Board, +Move)
% a move is zeroing if it is a capture or a pawn move
is_zeroing(Board, [From, _|_]) :-
    piece_at(Board, From, pawn).
is_zeroing(Board, [From, To|_]) :-
    is_capture(Board, [From, To]).

update_castling_rights(Board, [square(e1), _|_], NewBoard) :-
    piece_at(Board, piece(king, white), square(e1)),
    delete(Board, kingside_castle(white), Board_1),
    delete(Board_1, queenside_castle(white), NewBoard).
update_castling_rights(Board, [square(e8), _|_], NewBoard) :-
    piece_at(Board, piece(king, black), square(e8)),
    delete(Board, kingside_castle(black), Board_1),
    delete(Board_1, queenside_castle(black), NewBoard).
update_castling_rights(Board, [square(a1), _|_], NewBoard) :-
    piece_at(Board, piece(rook, white), square(a1)),
    delete(Board, queenside_castle(white), NewBoard).
update_castling_rights(Board, [square(h1), _|_], NewBoard) :-
    piece_at(Board, piece(rook, white), square(h1)),
    delete(Board, kingside_castle(white), NewBoard).
update_castling_rights(Board, [square(a8), _|_], NewBoard) :-
    piece_at(Board, piece(rook, black), square(a8)),
    delete(Board, queenside_castle(black), NewBoard).
update_castling_rights(Board, [square(h8), _|_], NewBoard) :-
    piece_at(Board, piece(rook, black), square(h8)),
    delete(Board, kingside_castle(black), NewBoard).
update_castling_rights(Board, _, Board).

% legal_move(++Board, +Move)
legal_move(Board, Move) :-
    fail.

% pseudo_legal_move(++Board, +Move)
pseudo_legal_move(Board, Move) :-
    fail.

unpack_move([From, To], From, To, []).
unpack_move([From, To, PromoPieceType], From, To, PromoPieceType).

get_ep_square(File, 7, File, 5, EpPred) :-
    coords(EpSq, File, 6),
    EpPred = [en_passant(EpSq)].
get_ep_square(File, 2, File, 4, EpPred) :-
    coords(EpSq, File, 3),
    EpPred = [en_passant(EpSq)].
get_ep_square(_, _, _, _, []).

set_ep_square(Board, piece(pawn, _), From, To, NewBoard) :-
    coords(From, FileF, RankF),
    coords(To, FileT, RankT),
    get_ep_square(FileF, RankF, FileT, RankT, EpPredList),
    delete(Board, en_passant(_), Board_1),
    append(Board_1, EpPredList, NewBoard).
set_ep_square(Board, _, _, _, NewBoard) :-
    delete(Board, en_passant(_), NewBoard).

make_ep_capture(Board, piece(pawn, Side), empty, square(FromAtom), square(ToAtom), NewBoard) :-
    coords(FromAtom, FileF, RankF),
    coords(ToAtom, FileT, RankT),
    DelF is FileT - FileF,
    DelR is RankT - RankF,
    pawn_attack_delta(Side, DelF, DelR),

    en_passant(Board, square(ToAtom)),
    
    other_color(Side, OtherSide),
    coords(Target, FileT, RankF),
    delete(Board, contents(piece(pawn, OtherSide), square(Target)), Board_1),
    delete(Board_1, en_passant(_), NewBoard).
make_ep_capture(Board, _, _, _, _, Board).

reset_if_zeroing(Board, Move, NewBoard) :-
    is_zeroing(Board, Move),
    reset_halfmove_clock(Board, NewBoard).
reset_if_zeroing(Board, _, Board).

placed_piece(MovedPiece, [], MovedPiece).
placed_piece(piece(_, Side), [piece_type(PromoTypeAtom)], piece(PromoTypeAtom, Side)).

swap_turn(Board, NewBoard) :-
    turn(Board, Side),
    other_color(Side, Other),
    delete(Board, turn(Side), Board_1),
    append(Board_1, [turn(Other)], NewBoard).

perform_castling(Board, square(e1), square(g1), piece(king, white), NewBoard) :-
    remove_piece_at(Board, square(h1), Board_1),
    set_piece_at(Board_1, piece(rook, white), square(f1), NewBoard).
perform_castling(Board, square(e1), square(c1), piece(king, white), NewBoard) :-
    remove_piece_at(Board, square(a1), Board_1),
    set_piece_at(Board_1, piece(rook, white), square(d1), NewBoard).
perform_castling(Board, square(e8), square(g8), piece(king, black), NewBoard) :-
    remove_piece_at(Board, square(h8), Board_1),
    set_piece_at(Board_1, piece(rook, black), square(f8), NewBoard).
perform_castling(Board, square(e8), square(c8), piece(king, black), NewBoard) :-
    remove_piece_at(Board, square(a8), Board_1),
    set_piece_at(Board_1, piece(rook, black), square(d8), NewBoard).
perform_castling(Board, _, _, PlacedPiece, Board).

make_move(Board, Move, NewBoard) :-
    unpack_move(Move, From, To, Promo),

    increment_halfmove_clock(Board, Board_1),
    increment_fullmove(Board_1, Board_2),
    reset_if_zeroing(Board_2, Move, Board_3),
    update_castling_rights(Board_3, Move, Board_4),

    piece_at(Board, MovedPiece, From),
    piece_at(Board, CapturedPiece, To),
    remove_piece_at(Board_4, From, Board_5),
    remove_piece_at(Board_5, To, Board_6),
    
    % handle special pawn moves (set ep square, remove pawn captured by ep)
    make_ep_capture(Board_6, MovedPiece, CapturedPiece, From, To, Board_7),
    set_ep_square(Board_7, MovedPiece, From, To, Board_8),

    % handle promotion - if promo, set new piece type to promo type
    placed_piece(MovedPiece, Promo, PlacedPiece),

    % handle castling - if possible (piece to be moved is King and adjacent square has own rook), perform that castle
    perform_castling(Board_8, From, To, PlacedPiece, Board_9),
    % if castling not possible, put target piece on target square
    set_piece_at(Board_9, PlacedPiece, To, Board_10),

    swap_turn(Board_10, Board_11),
    NewBoard = Board_11.

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

