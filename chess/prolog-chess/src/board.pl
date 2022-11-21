/** <module> Chess Game State
 *
 * Module to operate on a chess game state.
 * A chess game state is represented as a list of predicates -
 * 1. contents/2: identical to the BaseBoard representation, these represent the locations of pieces on the board
 * 2. turn/1: represents whose turn it is to play e.g., turn(white) or turn(black)
 * 3. kingside_castle/1, queenside_castle/1: represent whether a side has king/queen-side castling rights available
 * 4. fullmove/1: denotes the full move count
 * 5. halfmove_clock: denotes the half-move clock
 * 6. en_passant/1: denotes the en passant square
 *
 * @author Abhijeet Krishnan
 * @copyright (c)2022 Abhijeet Krishnan.
 * @license All rights reserved. Used with permission.
 */

:- ['colors.pl'].
:- ['piece_types.pl'].
:- ['squares.pl'].
:- ['pieces.pl'].
:- ['moves.pl'].
:- ['base_board.pl'].

/**
 * turn(+Board:board, Side:color) is det
 *
 * Returns the side whose turn it is to play.
 *
 * @param Board
 * @param Side
 */
turn(Board, Side) :-
    member(turn(Side), Board),
    color(Side).

/**
 * kingside_castle(+Board:board, +Side:color) is det
 *
 * Unifies if the given side has kingside castling rights available in the current board.
 *
 * @param Board
 * @param Side
 */
kingside_castle(Board, Side) :-
    member(kingside_castle(Side), Board).

/**
 * queenside_castle(+Board:board, +Side:color) is det
 *
 * Unifies if the given side has queenside castling rights available in the current board.
 *
 * @param Board
 * @param Side
 */
queenside_castle(Board, Side) :-
    member(queenside_castle(Side), Board).

/**
 * fullmove(+Board: board, -N:int) is det
 *
 * Returns the fullmove number of the current board.
 *
 * @param Board
 * @param N
 */
fullmove(Board, N) :-
    member(fullmove(N), Board).

/**
 * increment_fullmove(+Board:board, -NewBoard:board) is det
 *
 * Increments the fullmove number of the current board. 
 *
 * @param Board
 * @param NewBoard
 */
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

/**
 * halfmove_clock(+Board:board, -N:int) is det
 *
 * Returns the halfmove clock of the current board.
 *
 * @param Board
 * @param N
 */
halfmove_clock(Board, N) :-
    member(halfmove_clock(N), Board).

/**
 * set_halfmove_clock(+Board:board, +NewN:int, -NewBoard:board) is det
 *
 * Sets the halfmove clock of the current board to the desired value.
 *
 * @param Board
 * @param NewN
 * @param NewBoard
 */
set_halfmove_clock(Board, NewN, NewBoard) :-
    delete(Board, halfmove_clock(_), Board_1),
    %NewBoard = [halfmove_clock(NewN)|Board_1].
    append(Board_1, [halfmove_clock(NewN)], NewBoard).

/**
 * increment_halfmove_clock(+Board:board, -NewBoard:board) is det
 *
 * Increments the halfmove clock of the current board by 1.
 *
 * @param Board
 * @param NewBoard
 */
increment_halfmove_clock(Board, NewBoard) :-
    halfmove_clock(Board, N),
    NewN is N + 1,
    set_halfmove_clock(Board, NewN, NewBoard).

/**
 * reset_halfmove_clock(+Board:board, -NewBoard:board) is det
 *
 * Resets the halfmove clock to 0.
 *
 * @param Board
 * @param NewBoard
 */
reset_halfmove_clock(Board, NewBoard) :-
    set_halfmove_clock(Board, 0, NewBoard).

% en_passant(++Board, -Square)
/**
 * en_passant(+Board:board, -Square:square) is det
 *
 * Returns the en passant square, if any, in the current board.
 * If en passant square is absent, returns a special atom 'empty'.
 *
 * @param Board
 * @param Square
 */
en_passant(Board, Square) :-
    member(en_passant(Square), Board).
en_passant(_, empty).

/**
 * castling_rights_to_str(+CastlingChar:char, -CastlingPred:pred) is det
 *
 * Converts a character of the castling rights string in FEN to the corresponding predicate.
 *
 * @param CastlingChar Any one of ['K', 'k', 'Q', 'q']
 * @param CastlingPred
 */
castling_str_to_rights('K', kingside_castle(white)).
castling_str_to_rights('Q', queenside_castle(white)).
castling_str_to_rights('k', kingside_castle(black)).
castling_str_to_rights('q', queenside_castle(black)).

/**
 * castling_rights(CastleRightsStr:str, CastleRights:list(pred)) is det
 *
 * Convert a castling rights string in FEN to the list of predicates representing them.
 * e.g., "Kq" is converted to [kingside_castle(white), queenside_castle(black)].
 * Returns an empty list if the input string is "-" i.e. no castling rights are available.
 *
 * @param CastleRightsStr
 * @param CastleRights
 */
castling_rights("-", []).
castling_rights(CastleRightsStr, CastleRights) :-
    string_chars(CastleRightsStr, CastleRightsList),
    maplist(castling_str_to_rights, CastleRightsList, CastleRights).

/**
 * en_passant_sq(+EnPassantStr:str, -EnPassantPreds:list(pred)) is det
 *
 * Returns the unit list of predicates representing the en passant square from the FEN representation
 *
 * @param EnPassantStr
 * @param EnPassantPreds
 */
en_passant_sq("-", []).
en_passant_sq(EnPassantStr, EnPassantPreds) :-
    atom_string(EnPassantAtom, EnPassantStr),
    EnPassantPreds = [en_passant(EnPassantAtom)]. % assumes input string is a valid square

/**
 * set_board_fen(+Fen:str, -Board:board) is det
 *
 * Sets the board according to a FEN string.
 *
 * @param Fen
 * @param Board
 */
set_board_fen(Fen, Board) :-
    split_string(Fen, " ", "", [PosStr, TurnStr, CastleRightsStr, EpStr, HmClkStr, FmNumStr]),
    set_board_contents(PosStr, PosPreds),
    color_str(TurnCol, TurnStr),
    castling_rights(CastleRightsStr, CastleRightsPreds),
    en_passant_sq(EpStr, EpPred),
    number_string(HalfmoveClock, HmClkStr),
    number_string(Fullmove, FmNumStr),
    flatten([PosPreds, turn(TurnCol), CastleRightsPreds, EpPred, halfmove_clock(HalfmoveClock), fullmove(Fullmove)], Board), !.

/**
 * is_capture(+Board:board, +Move:move) is semidet
 *
 * Tests if a move is a capture.
 * A move is a capture if a piece of the opposing color lies on the square to which the move is being made.
 *
 * @param Board
 * @param Move
 */
is_capture(Board, [_, To|_]) :-
    turn(Board, Side),
    other_color(Side, OpposingSide),
    piece_at(Board, To, piece(_, OpposingSide)).

/**
 * is_zeroing(+Board:board, +Move:move) is semidet
 *
 * Tests if a move is "zeroing".
 * A move is zeroing if it is a capture or a pawn move.
 *
 * @param Board
 * @param Move
 */
is_zeroing(Board, [From, _|_]) :-
    piece_at(Board, From, pawn).
is_zeroing(Board, [From, To|_]) :-
    is_capture(Board, [From, To]).

/**
 * reset_if_zeroing(+Board:board, +Move:move, -NewBoard:board) is det
 *
 * Reset the halfmove clock if the input move is zeroing.
 *
 * @param Board
 * @param Move
 * @param NewBoard
 */
reset_if_zeroing(Board, Move, NewBoard) :-
    is_zeroing(Board, Move),
    reset_halfmove_clock(Board, NewBoard).
reset_if_zeroing(Board, _, Board).

/**
 * update_castling_rights(+Board:board, +Move:move, -NewBoard:board) is det
 *
 * Update the castling rights of the current board based on the input move made.
 * In case of a king move, both castling rights for that side are disabled.
 * In case of a rook move, the castling rights for that side are disabled.
 *
 * @param Board
 * @param Move
 * @param NewBoard
 */
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

/**
 * get_ep_square(+FileFrom:int, +RankFrom:int, +FileTo:int, +RankTo:int, -EpPred:list(pred)) is det
 *
 * Returns the unit list of predicates representing the en passant square from a pawn move represented as from and to
 * coordinates.
 *
 * @param FileFrom The file from which the pawn moves
 * @param RankFrom The rank from which the pawn moves
 * @param FileTo The file to which the pawn moves
 * @param RankTo The rank to which the pawn moves
 * @param EpPred
 */
get_ep_square(File, 7, File, 5, EpPred) :-
    coords(EpSq, File, 6),
    EpPred = [en_passant(EpSq)].
get_ep_square(File, 2, File, 4, EpPred) :-
    coords(EpSq, File, 3),
    EpPred = [en_passant(EpSq)].
get_ep_square(_, _, _, _, []).

/**
 * set_ep_square(+Board:board, +Piece:piece, +From:square, +To:square, -NewBoard:board) is det
 *
 * Sets (or deletes) the en passant square according to the input move.
 * Setting/deleting the en passant square operates according to regular chess rules.
 *
 * @param Board
 * @param Piece
 * @param From
 * @param To
 * @param NewBoard
 */
set_ep_square(Board, piece(pawn, _), From, To, NewBoard) :-
    coords(From, FileF, RankF),
    coords(To, FileT, RankT),
    get_ep_square(FileF, RankF, FileT, RankT, EpPredList),
    delete(Board, en_passant(_), Board_1),
    append(Board_1, EpPredList, NewBoard).
set_ep_square(Board, _, _, _, NewBoard) :-
    delete(Board, en_passant(_), NewBoard).

/**
 * make_ep_capture(+Board:board, +MovedPiece:piece, +CapturedPiece:piece, +FromPred:sq_pred, +ToPred:sq_pred, -NewBoard:board) is det
 *
 * Performs the en passant capture according to regular chess rules.
 *
 * @param Board
 * @param MovedPiece
 * @param CapturedPiece The piece being captured. Might be 'empty' in case there was no capture, or it was an en passant capture.
 * @param FromPred
 * @param ToPred
 * @param NewBoard
 */
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

/**
 * placed_piece(+MovedPiece:piece, +PromoPreds:list(pred), -PlacedPiece:piece) is det
 *
 * Return the new piece to be placed if there is a promotion.
 *
 * @param MovedPiece The original piece being moved
 * @param PromoPreds The list of predicate(s) representing the piece type to which the piece is being promoted
 * @param PlacedPiece The new piece type that must be placed instead
 */
placed_piece(MovedPiece, [], MovedPiece).
placed_piece(piece(_, Side), [piece_type(PromoTypeAtom)], piece(PromoTypeAtom, Side)).

/**
 * swap_turn(+Board:board, -NewBoard:board) is det
 *
 * Swap turns by changing the turn/1 predicate.
 *
 * @param Board
 * @param NewBoard
 */
swap_turn(Board, NewBoard) :-
    turn(Board, Side),
    other_color(Side, Other),
    delete(Board, turn(Side), Board_1),
    append(Board_1, [turn(Other)], NewBoard).

/**
 * perform_castling(+Board:board, +FromPred:sq_pred, +ToPred:sq_pred, +Piece:piece, -NewBoard:board) is det
 *
 * Perform castling based on the input move, returning the resultant board.
 *
 * @param Board
 * @param FromPred
 * @param ToPred
 * @param Piece The piece being moved
 * @param NewBoard
 */
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

/**
 * make_move(+Board:board, +Move:move, -NewBoard:board) is det
 *
 * Makes the input move in the current position, returning the resultant board state.
 *
 * @param Board
 * @param Move
 * @param NewBoard
 */
make_move(Board, Move, NewBoard) :-
    move(Move, From, To, Promo),

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

/**
 * ply(+Board:board, -Ply:int) is det
 *
 * Returns the number of plies in the current board.
 *
 * @param Board
 * @param Ply
 */
ply(Board, Ply) :-
    fullmove(Board, FullMove),
    turn(Board, Side),
    (
        Side = black ->
            Ply is 2 * FullMove + 1
        ;
            Ply is 2 * FullMove
    ).

/**
 * castling_move(+Board:board, -Move:move) is nondet
 *
 * Describes a legal castling move in the current board.
 *
 * @param Board
 * @param Move
 */
castling_move(Board, [e1, g1]) :-
    piece_at(Board, piece(king, white), e1),
    piece_at(Board, piece(rook, white), h1),
    turn(Board, white),
    is_empty(Board, [f1, g1]),
    \+ is_attacked(Board, f1, piece(_, black)),
    \+ is_attacked(Board, g1, piece(_, black)).
castling_move(Board, [e1, c1]) :-
    piece_at(Board, piece(king, white), e1),
    piece_at(Board, piece(rook, white), a1),
    turn(Board, white),
    is_empty(Board, [d1, c1, b1]),
    \+ is_attacked(Board, d1, piece(_, black)),
    \+ is_attacked(Board, c1, piece(_, black)).
castling_move(Board, [e8, g8]) :-
    piece_at(Board, piece(king, black), e8),
    piece_at(Board, piece(rook, black), h8),
    turn(Board, black),
    is_empty(Board, [f8, g8]),
    \+ is_attacked(Board, f8, piece(_, white)),
    \+ is_attacked(Board, g8, piece(_, white)).
castling_move(Board, [e8, c8]) :-
    piece_at(Board, piece(king, black), e8),
    piece_at(Board, piece(rook, black), a8),
    turn(Board, black),
    is_empty(Board, [d8, c8, b8]),
    \+ is_attacked(Board, d8, piece(_, white)),
    \+ is_attacked(Board, c8, piece(_, white)).



/**
 * is_into_check(+Board:board, +Move:move) is det
 *
 * Check if a given move would put the king into check.
 *
 * @param Board
 * @param Move
 */
is_into_check(Board, Move) :-
    fail.


/**
 * pseudo_legal_move(+Board:board, +Move:move) is det
 *
 * Checks if a given move is pseudo-legal.
 * A move is pseudo-legal if -
 * 1. it is a valid move i.e., it is [From, To] or [From, To, Promo]
 * 2. the source square contains a piece
 * 3. piece being moved belongs to side whose turn it is to play
 * 4. if the move is a promotion, the moved piece is a pawn on the correct rank
 * 5. if the move is a castle, it is permissible depending on available castling rights
 * 6. the destination square is NOT occupied
 *
 * @param Board
 * @param Move
 */
pseudo_legal_move(Board, Move) :-
    fail.

% legal_move(++Board, +Move)
legal_move(Board, Move) :-
    fail.

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

outcome(checkmate).
outcome(stalemate).
outcome(insufficient_material).
outcome(seventyfile_move_rule).
outcome(fivefold_repetition).
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

