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
:- module(board, [
    turn/2, 
    kingside_castle/2, 
    queenside_castle/2, 
    fullmove/2, 
    halfmove_clock/2, 
    en_passant/2, 
    set_board_fen/2, 
    is_capture/2, 
    can_capture/3, 
    is_zeroing/2, 
    ply/2, 
    pseudo_legal_move/2, 
    into_check/2, 
    legal_move/2
]).

:- use_module(colors).
:- use_module(piece_types).
:- use_module(squares).
:- use_module(pieces).
:- use_module(moves).
:- use_module(square_set).
:- use_module(base_board).
:- use_module(make_move).

/**
 * turn(+Board:board, -Side:color) is det
 *
 * Returns the side whose turn it is to play.
 *
 * @param Board
 * @param Side
 */
turn(Board, Side) :-
    % write_term(Board, [quoted(true), brace_terms(true)]),
    member(turn(Side), Board),
    % writeln(Board),
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
    piece_at(Board, piece(_, OpposingSide), To).

/**
 * can_capture(+Board:board, +Square:square, -CaptureSquare:square) is nondet
 *
 * Checks if the piece at the given Square can capture an opposing piece at another square.
 *
 * @param Board
 * @param Square
 * @param CaptureSquare
 */
can_capture(Board, Square, CaptureSquare) :-
    turn(Board, Side),
    other_color(Side, OtherSide),
    can_attack(Board, Square, CaptureSquare),
    piece_at(Board, piece(_, OtherSide), CaptureSquare).

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
    piece_at(Board, piece(pawn, _), From).
is_zeroing(Board, [From, To|_]) :-
    is_capture(Board, [From, To]).

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
    kingside_castle(Board, white),
    piece_at(Board, piece(king, white), e1),
    piece_at(Board, piece(rook, white), h1),
    turn(Board, white),
    is_empty(Board, [f1, g1]),
    \+ is_attacked(Board, e1, piece(_, black)),
    \+ is_attacked(Board, f1, piece(_, black)),
    \+ is_attacked(Board, g1, piece(_, black)).
castling_move(Board, [e1, c1]) :-
    queenside_castle(Board, white),
    piece_at(Board, piece(king, white), e1),
    piece_at(Board, piece(rook, white), a1),
    turn(Board, white),
    is_empty(Board, [d1, c1, b1]),
    \+ is_attacked(Board, e1, piece(_, black)),
    \+ is_attacked(Board, d1, piece(_, black)),
    \+ is_attacked(Board, c1, piece(_, black)).
castling_move(Board, [e8, g8]) :-
    kingside_castle(Board, black),
    piece_at(Board, piece(king, black), e8),
    piece_at(Board, piece(rook, black), h8),
    turn(Board, black),
    is_empty(Board, [f8, g8]),
    \+ is_attacked(Board, e8, piece(_, white)),
    \+ is_attacked(Board, f8, piece(_, white)),
    \+ is_attacked(Board, g8, piece(_, white)).
castling_move(Board, [e8, c8]) :-
    queenside_castle(Board, black),
    piece_at(Board, piece(king, black), e8),
    piece_at(Board, piece(rook, black), a8),
    turn(Board, black),
    is_empty(Board, [d8, c8, b8]),
    \+ is_attacked(Board, e8, piece(_, white)),
    \+ is_attacked(Board, d8, piece(_, white)),
    \+ is_attacked(Board, c8, piece(_, white)).

/**
 * pseudo_legal_ep(+Board:board, -Move:move) is nondet
 *
 * Generates pseudo-legal en passant captures for the current side in the input board.
 *
 * @param Board
 * @param Move
 */
pseudo_legal_ep(Board, [From, To]) :-
    en_passant(Board, EpSq),
    EpSq \== empty,                           % en passant square must exist
    To = EpSq,                                % move must be to en passant square
    is_empty(Board, [EpSq]),                  % en passant square must not be occupied
    turn(Board, Side),
    piece_at(Board, piece(pawn, Side), From),
    attack_square(From, pawn, Side, EpSq).    % pawn of playing side must attack en passant square

/**
 * pawn_capture(+Board:board, -Move:move) is nondet
 *
 * Defines a pseudo-legal pawn capture on the current board.
 *
 * @param Board
 * @param Move
 */
pawn_capture(Board, [From, To]) :-
    turn(Board, Side),
    coords(From, _, FromRank),
    \+ promo_rank(Side, FromRank),
    other_color(Side, OtherSide),
    piece_at(Board, piece(pawn, Side), From),
    can_attack(Board, From, To),
    piece_at(Board, piece(_, OtherSide), To).
pawn_capture(Board, [From, To, Promo]) :-
    turn(Board, Side),
    coords(From, _, FromRank),
    promo_rank(Side, FromRank),
    promo_piece(Promo),
    other_color(Side, OtherSide),
    piece_at(Board, piece(pawn, Side), From),
    can_attack(Board, From, To),
    piece_at(Board, piece(_, OtherSide), To).

/**
 * pseudo_legal_move_(+Board:board, +Type: p_type, +Side:color, -From:square, -To:square[, -Promo:p_type]) is nondet
 *
 * Helper method for generating pseudo-legal moves (or checking if a move is pseudo-legal).
 *
 * @param Board
 * @param Type
 * @param Side
 * @param From
 * @param To
 * @param [Promo]
 */
pseudo_legal_move_(Board, pawn, Side, From, To, Promo) :- % pawn capture (promo)
    coords(From, _, FromRank),
    promo_rank(Side, FromRank),
    promo_piece(Promo),
    other_color(Side, OtherSide),
    can_attack(Board, From, To),
    piece_at(Board, piece(_, OtherSide), To).
pseudo_legal_move_(Board, pawn, Side, From, To, Promo) :- % pawn single move (promo)
    coords(From, _, FromRank),
    promo_rank(Side, FromRank),
    promo_piece(Promo),
    pawn_single_move(Side, From, To),
    is_empty(Board, [To]).
pseudo_legal_move_(Board, pawn, Side, From, To) :- % pawn single move (non-promo)
    coords(From, _, FromRank),
    \+ promo_rank(Side, FromRank),
    pawn_single_move(Side, From, To),
    is_empty(Board, [To]).
    pseudo_legal_move_(Board, pawn, Side, From, To) :- % pawn capture (non-promo)
    coords(From, _, FromRank),
    \+ promo_rank(Side, FromRank),
    other_color(Side, OtherSide),
    can_attack(Board, From, To),
    piece_at(Board, piece(_, OtherSide), To).
pseudo_legal_move_(Board, pawn, Side, From, To) :- % pawn double move
    pawn_double_move(Side, From, Middle, To),
    is_empty(Board, [Middle, To]).
pseudo_legal_move_(Board, pawn, _, From, To) :- % en passant move
    pseudo_legal_ep(Board, [From, To]).
pseudo_legal_move_(Board, king, _, From, To) :- % castling move
    castling_move(Board, [From, To]).
pseudo_legal_move_(Board, Type, _, From, To) :- % piece move
    Type \== pawn,
    can_attack(Board, From, To),
    piece_at(Board, empty, To).
pseudo_legal_move_(Board, Type, Side, From, To) :- % piece capture
    Type \== pawn,
    other_color(Side, OtherSide),
    can_attack(Board, From, To),
    piece_at(Board, piece(_, OtherSide), To).

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
pseudo_legal_move(Board, [From, To, Promo]) :-
    turn(Board, Side),
    piece_at(Board, piece(pawn, Side), From),
    pseudo_legal_move_(Board, pawn, Side, From, To, Promo).
pseudo_legal_move(Board, [From, To]) :-
    turn(Board, Side),
    piece_at(Board, piece(Type, Side), From),
    pseudo_legal_move_(Board, Type, Side, From, To).

/**
 * into_check(+Board:board, +Move:move, -Checker:piece) is nondet
 *
 * Check if a given move would put the king into check.
 * In the position after the move is played, search for a piece that could "capture" the king.
 *
 * @param Board
 * @param Move
 * @param Checker The piece which is checking the king after the move
 */
into_check(Board, Move, Checker) :-
    turn(Board, Side),
    make_move(Board, Move, NewBoard),
    piece_at(NewBoard, piece(king, Side), KingSq),
    pseudo_legal_move(NewBoard, [From, KingSq|_]), % check if any piece can "capture" the king
    piece_at(NewBoard, Checker, From).

/**
 * legal_move(+Board:board, -Move:move) is nondet
 *
 * Defines a legal chess move.
 * A move is legal if it is pseudo-legal and does not lead to the king being in check.
 *
 * @param Board
 * @param Move
 */
legal_move(Board, Move) :-
    pseudo_legal_move(Board, Move),
    \+ into_check(Board, Move, _).

% % Gets the pieces currently giving check
% checkers(Board, Checkers) :-
%     fail.

% % Tests if the current side to move is in check
% in_check(Board) :-
%     fail.

% % Probes if the given move would put the opponent in check. The move must be at least pseudo-legal.
% gives_check(Board, Move) :-
%     pseudo_legal_move(Board, Move),
%     make_move(Board, Move, NewBoard),
%     in_check(NewBoard).

% outcome(checkmate).
% outcome(stalemate).
% outcome(insufficient_material).
% outcome(seventyfile_move_rule).
% outcome(fivefold_repetition).
% outcome(Board, Outcome) :-
%     outcome(Outcome),
%     fail.

% is_checkmate(Board) :-
%     fail.

% is_stalemate(Board) :-
%     fail.

% is_insufficient_material(Board) :-
%     fail.

% has_insufficient_material(Board, Color) :-
%     fail.

% is_seventyfive_moves(Board) :-
%     fail.

% is_fivefold_repetition(Board) :-
%     fail.