#!/usr/bin/env python

import sys

from pyswip import Prolog

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

pos = []
neg = []

tp, tn, fp, fn = 0, 0, 0, 0

with open('exs.pl') as examples_file:
    for line in examples_file:
        line = line.strip()
        args = line[5:-2]
        if line.startswith('pos'):
            pos.append(args)
        elif line.startswith('neg'):
            neg.append(args)
        else:
            raise NotImplementedError(f'Examples must be either pos or neg, found {line[:3]}')

target_reln = sys.argv[1]

prolog = Prolog()
prolog.consult('bk.pl')

for example in pos:
    result = list(prolog.query(f'distinct({target_reln}{example})'))
    if len(result) > 0:
        print(f'{bcolors.OKGREEN}pos({target_reln}{example}){bcolors.ENDC}')
        tp += 1
    else:
        print(f'{bcolors.FAIL}pos({target_reln}{example}){bcolors.ENDC}')
        fn += 1

for example in neg:
    result = list(prolog.query(f'distinct({target_reln}{example})'))
    if len(result) > 0:
        print(f'{bcolors.FAIL}neg({target_reln}{example}){bcolors.ENDC}')
        fp += 1
    else:
        print(f'{bcolors.OKGREEN}neg({target_reln}{example}){bcolors.ENDC}')
        tn += 1
print(f'TP:{tp}, FN:{fn}, TN:{tn}, FP:{fp}, Total:{tp + fn + tn + fp}')