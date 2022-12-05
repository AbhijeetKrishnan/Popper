/** <module> make_move
 *
 * Implements the make_move/3 predicate that simulates the effects of making a move in chess.
 *
 * @author Abhijeet Krishnan
 * @copyright (c)2022 Abhijeet Krishnan.
 * @license All rights reserved. Used with permission.
 */
:- module(make_move, [
    make_move/3
]).

:- use_module(colors).
:- use_module(piece_types).
:- use_module(squares).
:- use_module(pieces).
:- use_module(moves).
:- use_module(square_set).
:- use_module(base_board).
:- use_module(board).

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
 * reset_if_zeroing(+Board:board, +Move:move, -NewBoard:board) is det
 *
 * Reset the halfmove clock if the input move is zeroing.
 *
 * @param Board
 * @param Move
 * @param NewBoard
 */
reset_if_zeroing(Board, Move, NewBoard) :-
    (
        is_zeroing(Board, Move) ->
            reset_halfmove_clock(Board, NewBoard)
        ;
            increment_halfmove_clock(Board, NewBoard)
    ).

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
update_castling_rights(Board, [e1, _|_], NewBoard) :-
    piece_at(Board, piece(king, white), e1),
    delete(Board, kingside_castle(white), Board_1),
    delete(Board_1, queenside_castle(white), NewBoard).
update_castling_rights(Board, [e8, _|_], NewBoard) :-
    piece_at(Board, piece(king, black), e8),
    delete(Board, kingside_castle(black), Board_1),
    delete(Board_1, queenside_castle(black), NewBoard).
update_castling_rights(Board, [a1, _|_], NewBoard) :-
    piece_at(Board, piece(rook, white), a1),
    delete(Board, queenside_castle(white), NewBoard).
update_castling_rights(Board, [h1, _|_], NewBoard) :-
    piece_at(Board, piece(rook, white), h1),
    delete(Board, kingside_castle(white), NewBoard).
update_castling_rights(Board, [a8, _|_], NewBoard) :-
    piece_at(Board, piece(rook, black), a8),
    delete(Board, queenside_castle(black), NewBoard).
update_castling_rights(Board, [h8, _|_], NewBoard) :-
    piece_at(Board, piece(rook, black), h8),
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
make_ep_capture(Board, piece(pawn, Side), empty, FromAtom, ToAtom, NewBoard) :-
    coords(FromAtom, FileF, RankF),
    coords(ToAtom, FileT, RankT),
    DelF is FileT - FileF,
    DelR is RankT - RankF,
    pawn_attack_delta(Side, DelF, DelR),

    en_passant(Board, ToAtom),
    
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
perform_castling(Board, e1, g1, piece(king, white), NewBoard) :-
    remove_piece_at(Board, h1, Board_1),
    set_piece_at(Board_1, piece(rook, white), f1, NewBoard).
perform_castling(Board, e1, c1, piece(king, white), NewBoard) :-
    remove_piece_at(Board, a1, Board_1),
    set_piece_at(Board_1, piece(rook, white), d1, NewBoard).
perform_castling(Board, e8, g8, piece(king, black), NewBoard) :-
    remove_piece_at(Board, h8, Board_1),
    set_piece_at(Board_1, piece(rook, black), f8, NewBoard).
perform_castling(Board, e8, c8, piece(king, black), NewBoard) :-
    remove_piece_at(Board, a8, Board_1),
    set_piece_at(Board_1, piece(rook, black), d8, NewBoard).
perform_castling(Board, _, _, _, Board).

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
    move(Move, square(From), square(To), PromoList),

    increment_fullmove(Board, Board_1),
    reset_if_zeroing(Board_1, Move, Board_2),
    update_castling_rights(Board_2, Move, Board_3),

    piece_at(Board, MovedPiece, From),
    piece_at(Board, CapturedPiece, To),
    remove_piece_at(Board_3, From, Board_4),
    remove_piece_at(Board_4, To, Board_5),
    
    % handle special pawn moves (set ep square, remove pawn captured by ep)
    make_ep_capture(Board_5, MovedPiece, CapturedPiece, From, To, Board_6),
    set_ep_square(Board_6, MovedPiece, From, To, Board_7),

    % handle promotion - if promo, set new piece type to promo type
    placed_piece(MovedPiece, PromoList, PlacedPiece),

    % handle castling - if possible (piece to be moved is King and adjacent square has own rook), perform that castle
    perform_castling(Board_7, From, To, PlacedPiece, Board_8),
    % if castling not possible, put target piece on target square
    set_piece_at(Board_8, PlacedPiece, To, Board_9),

    swap_turn(Board_9, Board_10),
    NewBoard = Board_10,
    !.