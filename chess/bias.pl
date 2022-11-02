max_clauses(1).
max_vars(5).
max_body(5).

% enable_pi.

head_pred(f, 3).
type_limit(sq, 3).

body_pred(attacks, 3).
body_pred(make_move, 4).
body_pred(different_pos, 2).
body_pred(behind, 4).
body_pred(piece_at, 4).
body_pred(other_side, 2).
body_pred(legal_move, 3).

type(f, (pos, sq, sq)).
type(attacks, (sq, sq, pos)).
type(make_move, (sq, sq, pos, pos)).
type(different_pos, (sq, sq)).
type(behind, (sq, sq, sq, pos)).
type(piece_at, (sq, pos, side, piece)).
type(other_side, (side, side)).
type(legal_move, (sq, sq, pos)).

direction(f, (in, in, in)).
direction(attacks, (in, out, in)).
direction(make_move, (in, in, in, out)).
direction(different_pos, (in, in)).
direction(behind, (in, out, out, in)).
direction(piece_at, (in, in, in, out)).
direction(other_side, (in, in)).
direction(legal_move, (out, out, in)).

irreflexive(different_pos, 2).
irreflexive(other_side, 2).

transitive(different_pos, 2).
transitive(other_side, 2).