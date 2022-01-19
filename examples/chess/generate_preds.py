#!/usr/bin/env python

import string

for col, file in enumerate(string.ascii_lowercase[:8]):
    for rank in range(1, 9):
        print(f'to_coords({file}{rank}, {col+1}, {rank}).')