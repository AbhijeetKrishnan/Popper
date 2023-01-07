# Source: https://stackoverflow.com/a/24490005

import pyparsing as pp


DIRS = {
    'mirror': [0, 1],
    'different': [0, 0],
    'sq_between_non_incl': [0, 0, 1],
    'attack_squares': [0, 0, 0, 1],
    'piece': [0, 0],
    'piece_type': [1],
    'sliding': [1],
    'color': [1],
    'other_color': [0, 1],
    'move': [0, 1, 1, 1],
    'remove_piece_at': [0, 0, 1],
    'valid_piece_at': [0, 1, 1, 0],
    'xrays': [0, 0, 1, 1],
    'is_empty': [0, 0],
    'can_attack': [0, 0, 1],
    'is_attacked': [0, 0, 1],
    'turn': [0, 1],
    'kingside_castle': [0, 1],
    'queenside_castle': [0, 1],
    'en_passant': [0, 1],
    'is_capture': [0, 0],
    'can_capture': [0, 0, 1],
    'is_zeroing': [0, 0],
    'make_move': [0, 0, 1],
    'castling_move': [0, 1],
    'pawn_capture': [0, 1],
    'pseudo_legal_ep': [0, 1],
    'pseudo_legal_move': [0, 1],
    'in_check': [0, 0, 1],
    'into_check': [0, 0, 1],
    'legal_move': [0, 1],
}

def get_in_vars(pred):
    in_vars = set()
    for var, out in zip(pred.args, DIRS[pred.id]):
        if out == 0:
            in_vars.add(var)
    return in_vars

def get_out_vars(pred):
    in_vars = set()
    for var, out in zip(pred.args, DIRS[pred.id]):
        if out == 1:
            in_vars.add(var)
    return in_vars

def create_parser():
    predicate = pp.Word(pp.alphas + '_').set_results_name('id')

    number = pp.Word(pp.nums + '.').set_parse_action(lambda s, l, t: [int(t[0])])
    variable = pp.Word(pp.alphas + pp.nums + '_')

    # an argument to a fact can be either a number or a variable
    simple_arg = number | variable

    # arguments are a delimited list of 'argument' surrounded by parenthesis
    simple_arg_list = pp.Group(pp.Suppress('(') + pp.delimited_list(simple_arg, delim=',') +
                               pp.Suppress(')'))
    
    arg = simple_arg | simple_arg_list

    arguments = (pp.Suppress('(') + pp.delimited_list(arg, delim=',') + 
                 pp.Suppress(')')).set_results_name('args')

    fact = (predicate + arguments)

    comment = pp.Literal('%') + pp.Word(pp.alphanums + '_' + ' ' + ',' + ':')

    rule = (pp.Group(fact) + pp.Suppress(pp.Literal(':-')) + pp.delimited_list(pp.Group(fact), delim=',') + pp.Suppress('.'))

    prolog_parser = pp.OneOrMore(pp.Group(rule)).ignore(comment)
    return rule

def to_pred_str(predicate) -> str:
    return f'{predicate.id}/{len(predicate.args)}'

def to_pred(predicate) -> str:
    "Converts a parsed predicate into its string representation"

    return f'{predicate.id}({",".join(predicate.args)})'

def get_pred_str_list(results):
    return [to_pred_str(predicate) for predicate in results]

def sort_pred_list(preds):
    N = len(preds)
    grounded = {'A'}
    sorted_pred_list = []
    seen = set()
    while len(sorted_pred_list) < N:
        for idx, pred in enumerate(preds):
            if to_pred(pred) in seen:
                continue
            in_vars = get_in_vars(pred)
            out_vars = get_out_vars(pred)
            # print(idx, pred, pred.args, in_vars, out_vars, sorted_pred_list, seen)
            if in_vars.issubset(grounded):
                sorted_pred_list.append(pred)
                grounded.update(out_vars)
                seen.add(to_pred(pred))
    return sorted_pred_list

def parse_result_to_str(parse_result) -> str:
    "Converts a parsed hypothesis space into a list of tactics represented by strings"

    head_pred_str = to_pred(parse_result[0])
    body_preds = parse_result[1:]
    # body_preds.sort(key=lambda pred: ''.join(pred.args))
    body_preds = sort_pred_list(body_preds)
    body_preds_str = ','.join([to_pred(pred) for pred in body_preds])
    tactic_str = f'{head_pred_str}:-{body_preds_str}'
    return tactic_str

def get_all_unique_args(results):
    res = []
    for predicate in results:
        res.extend(predicate.args)
    return list(set(res))

if __name__ == '__main__':
    prolog_sentences = create_parser()

    test="""f(A,B):-pseudo_legal_move(A,B),make_move(A,B,D),pseudo_legal_ep(C,B),make_move(D,B,C)."""
    # f(A,B):-pseudo_legal_move(A,B),make_move(A,B,D),is_capture(C,B),make_move(D,B,C).
    # f(A,B):-pseudo_legal_move(A,B),make_move(A,B,D),make_move(C,B,A),make_move(D,B,C)."""

    result = prolog_sentences.parse_string(test, parse_all=True)
    tactic_str = parse_result_to_str(result)
    print(tactic_str)