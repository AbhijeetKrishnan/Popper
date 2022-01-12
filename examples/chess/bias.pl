max_clauses(5).
max_vars(7).
max_body(4).

% enable_pi.

head_pred(f,5).

body_pred(make_move,6).
body_pred(behind, 7).
body_pred(pieceAt, 5).
body_pred(other_side, 2).
body_pred(attacks,5).
body_pred(different_pos,4).

type(f, (list, element, element, element, element)).
type(make_move, (element, element, element, element, list, list)).
type(attacks, (element, element, element, element, list)).
type(different_pos, (element, element, element, element)).
type(behind, (element, element, element, element, element, element, list)).
type(pieceAt, (element, element, list, element, element)).
type(other_side, (element, element)).