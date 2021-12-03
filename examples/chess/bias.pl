max_clauses(1).
max_vars(7).
max_body(4).

head_pred(f,5).

body_pred(make_move,6).
body_pred(attacks,5).
body_pred(different_pos,4).

type(f, (list, element, element, element, element)).
type(make_move, (element, element, element, element, list, list)).
type(attacks, (element, element, element, element, list)).
type(different_pos, (element, element, element, element)).