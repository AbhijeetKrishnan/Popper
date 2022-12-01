max_clauses(1).
max_vars(5).
max_body(5).

% enable_pi.

head_pred(f, 2).
type_limit(sq, 3).

% body_pred(pseudo_legal_move, 2).
% body_pred(into_check, 3).
body_pred(legal_move, 2).

type(f, (board, move)).
% type(pseudo_legal_move, (board, move)).
% type(into_check, (board, move, piece)).
type(legal_move, (board, move)).

direction(f, (in, in)).
% direction(pseudo_legal_move, (in, out)).
% direction(into_check, (in, in, out)).
direction(legal_move, (in, out)).