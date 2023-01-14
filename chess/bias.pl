max_clauses(1).
max_vars(6).
max_body(6).

% enable_pi.
allow_singletons.

type_limit(sq, 3).

head_pred(f, 2).
type(f, (board, move)).
direction(f, (in, out)).

body_pred(mirror, 2).
type(mirror, (square, square)).
direction(mirror, (in, out)).

body_pred(different, 2).
type(different, (square, square)).
direction(different, (in, in)).

% body_pred(distance, 3).
% type(distance, (square, square, int)).
% direction(distance, (in, in, out)).

% body_pred(coords, 3).
% type(coords, (square, int, int)).
% direction(coords, (out, out, out)).

body_pred(sq_between_non_incl, 3).
type(sq_between_non_incl, (square, square, square)).
direction(sq_between_non_incl, (in, in, out)).

body_pred(attack_squares, 4).
type(attack_squares, (square, p_type, color, sqset)).
direction(attacks_squares, (in, in, in, out)).

body_pred(piece, 2).
type(piece, (p_type, color)).
direction(piece, (in, in)).

body_pred(piece_type, 1).
type(piece_type, (p_type,)).
direction(piece_type, (out,)).

body_pred(sliding, 1).
type(sliding, (p_type,)).
direction(sliding, (out,)).

body_pred(color, 1).
type(color, (color,)).
direction(color, (out,)).

body_pred(other_color, 2).
type(other_color, (color, color)).
direction(other_color, (in, out)).

body_pred(move, 4).
type(move, (move, square, square, list)).
direction(move, (in, out, out, out)).

% body_pred(piece_at, 3).
% type(piece_at, (board, piece, square)).
% direction(piece_at, (in, out, in)).

body_pred(remove_piece_at, 3).
type(remove_piece_at, (board, square, board)).
direction(remove_piece_at, (in, in, out)).

% body_pred(valid_piece, 3).
% type(valid_piece, (piece, p_type, color)).
% direction(valid_piece, (in, out, out)).

body_pred(valid_piece_at, 4).
type(valid_piece_at, (board, p_type, color, square)).
direction(valid_piece_at, (in, out, out, in)).

body_pred(xrays, 4).
type(xrays, (board, square, square, square)).
direction(xrays, (in, in, out, out)).

body_pred(is_empty, 2).
type(is_empty, (board, sqset)).
direction(is_empty, (in, in)).

body_pred(can_attack, 3).
type(can_attack, (board, square, square)).
direction(can_attack, (in, in, out)).

body_pred(is_attacked, 3).
type(is_attacked, (board, square, sqset)).
direction(is_attacked, (in, in, out)).

body_pred(turn, 2).
type(turn, (board, color)).
direction(turn, (in, out)).

body_pred(kingside_castle, 2).
type(kingside_castle, (board, color)).
direction(kingside_castle, (in, out)).

body_pred(queenside_castle, 2).
type(queenside_castle, (board, color)).
direction(queenside_castle, (in, out)).

% body_pred(fullmove, 2).
% type(fullmove, (board, int)).
% direction(fullmove, (in, out)).

% body_pred(halfmove_clock, 2).
% type(halfmove_clock, (board, int)).
% direction(halfmove_clock, (in, out)).

body_pred(en_passant, 2).
type(en_passant, (board, square)).
direction(en_passant, (in, out)).

body_pred(is_capture, 2).
type(is_capture, (board, move)).
direction(is_capture, (in, in)).

body_pred(can_capture, 3).
type(can_capture, (board, square, square)).
direction(can_capture, (in, in, out)).

body_pred(is_zeroing, 2).
type(is_zeroing, (board, move)).
direction(is_zeroing, (in, in)).

% body_pred(ply, 2).
% type(ply, (board, int)).
% direction(ply, (in, out)).

body_pred(make_move, 3).
type(make_move, (board, move, board)).
direction(make_move, (in, in, out)).

body_pred(castling_move, 2).
type(castling_move, (board, move)).
direction(castling_move, (in, out)).

body_pred(pawn_capture, 2).
type(pawn_capture, (board, move)).
direction(pawn_capture, (in, out)).

body_pred(pseudo_legal_ep, 2).
type(pseudo_legal_ep, (board, move)).
direction(pseudo_legal_ep, (in, out)).

body_pred(pseudo_legal_move, 2).
type(pseudo_legal_move, (board, move)).
direction(pseudo_legal_move, (in, out)).

body_pred(in_check, 3).
type(in_check, (board, color, square)).
direction(in_check, (in, in, out)).

body_pred(into_check, 3).
type(into_check, (board, move, piece)).
direction(into_check, (in, in, out)).

body_pred(legal_move, 2).
type(legal_move, (board, move)).
direction(legal_move, (in, out)).