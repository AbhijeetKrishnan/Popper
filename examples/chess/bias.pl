max_clauses(1).
max_vars(5).
max_body(5).

% enable_pi.

head_pred(f,3).

body_pred(attacks, 3).
body_pred(make_move, 4).
body_pred(different_pos, 2).
body_pred(behind, 4).
body_pred(piece_at, 4).
body_pred(other_side, 2).



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%body_pred(make_move, 4).

%body_pred(different_pos, 2).

%body_pred(fork,3).

%type(fork, (list, element, element)).
%type(make_move, (element, element, list, list)).

%type(different_pos, (element, element)).

%direction(make_move, (in, in, in, out)).

%direction(different_pos, (out, out)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%body_pred(pin, 3).



%type(pin, (list, element, element)).
type(f, (list, element, element)).
type(attacks, (element, element, list)).
type(make_move, (element, element, list, list)).
type(different_pos, (element, element)).
type(behind, (element, element, element, list)).
type(piece_at, (element, list, element, element)).
type(other_side, (element, element)).

direction(f, (in, in, in)).
direction(attacks, (in, out, out)).
direction(make_move, (in, in, in, out)).
direction(different_pos, (out, out)).
direction(behind, (in, out, out, in)).
direction(piece_at, (in, in, in, out)).
direction(other_side, (in, in)).