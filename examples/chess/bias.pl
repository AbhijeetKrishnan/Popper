max_clauses(1).
max_vars(6).
max_body(6).

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
type(f, (pos, sq, sq)).
type(attacks, (sq, sq, pos)).
type(make_move, (sq, sq, pos, pos)).
type(different_pos, (sq, sq)).
type(behind, (sq, sq, sq, pos)).
type(piece_at, (sq, pos, side, piece)).
type(other_side, (side, side)).

direction(f, (in, in, in)).
direction(attacks, (in, out, out)).
direction(make_move, (in, in, in, out)).
direction(different_pos, (out, out)).
direction(behind, (in, out, out, in)).
direction(piece_at, (in, in, in, out)).
direction(other_side, (in, in)).