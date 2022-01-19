max_clauses(1).
max_vars(6).
max_body(7).

% enable_pi.

head_pred(f,3).

body_pred(make_move,4).
body_pred(behind, 4).
body_pred(pieceAt, 4).
body_pred(other_side, 2).
%body_pred(attacks,5).
body_pred(different_pos, 2).
%body_pred(pin, 3).

type(f, (list, element, element)).
% type(pin, (list, element, element)).
type(make_move, (element, element, list, list)).
% type(attacks, (element, element, element, element, list)).
type(different_pos, (element, element)).
type(behind, (element, element, element, list)).
type(pieceAt, (element, list, element, element)).
type(other_side, (element, element)).