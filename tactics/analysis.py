#!/usr/bin/env python3

import argparse
import logging

from typing import List, Optional

logger = logging.getLogger(__name__)

import numpy as np
import pandas as pd

def get_top_tactics(df, filter: Optional[int]) -> List[str]:
    agg = df.groupby('tactic_text').aggregate(np.nansum)
    agg['avg_tactic_ground_div'] = agg['tactic_ground_div'] / agg['match']
    # agg['coverage'] = agg['matches'] / df.groupby(['position', 'move']).ngroups
    # agg['accuracy'] = agg['correct_move'] / agg['matches']
    final = agg.sort_values(by = ['avg_tactic_ground_div'], ascending = [True])
    tactics = list(final.index)
    if filter:
        target_len = int(len(tactics) * filter / 100)
        tactics = tactics[:target_len]
    return list(tactics)

def parse_args():
    parser = argparse.ArgumentParser(description='Analyze metrics and return top tactics')
    parser.add_argument('metrics_file', type=str, help='file containing tactic metrics')
    parser.add_argument('--log', dest='log_level', choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'], help='Set the logging level', default='INFO')
    parser.add_argument('-o', '--output', dest='output_file', type=str, help='File to which to write top tactics')
    parser.add_argument('--filter', dest='filter_limit', type=int, default=None, help='Percentage of top tactics to include in output')
    return parser.parse_args()

def main():
    args = parse_args()

    df = pd.read_csv(args.metrics_file)
    tactics = get_top_tactics(df, args.filter_limit)
    tactic_str = '\n'.join([tactic + '.' for tactic in tactics])
    if not args.output_file:
        print(tactic_str)
    else:
        with open(args.output_file, 'w') as output:
            output.write(tactic_str)

if __name__ == '__main__':
    main()