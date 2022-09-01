#!/usr/bin/env python3

import argparse
import logging
from typing import Optional

logger = logging.getLogger(__name__)

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt


def calculate_metrics(df):
    agg = df.groupby('tactic_text').aggregate(np.nansum)
    agg['avg_tactic_ground_div'] = agg['tactic_ground_div'] / agg['match']
    agg['coverage'] = agg['match'] / df.groupby(['position', 'move']).ngroups
    agg['accuracy'] = agg['correct_move'] / agg['match']
    return agg

def generate_frequency_graph(df, metric_fname: str, filename: str, title: str='?', xlabel: str=None, bins: int=10, left: int=0, right: Optional[int]=None):
    plt.hist(df[metric_fname], bins=bins)
    plt.axvline(df.loc[["f(A,B,C):-legal_move(B,C,A)"]][metric_fname].values, linestyle='dashed') # random baseline performance
    plt.title(f'Histogram of {title}')
    plt.xlabel(xlabel if xlabel else metric_fname)
    plt.ylabel('Frequency')
    plt.xlim(left=left, right=right)
    plt.savefig(filename)

def parse_args():
    parser = argparse.ArgumentParser(description='Generate frequency graph for a particular metric from an evaluated set of tactics')
    parser.add_argument('metrics_file', type=str, help='file containing tactic metrics')
    parser.add_argument('--log', dest='log_level', choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'], help='Set the logging level', default='INFO')
    parser.add_argument('-m', '--metric', dest='metric', type=str)
    parser.add_argument('-o', '--output', dest='output_name', type=str, help='File to which to output graph')
    parser.add_argument('--title', dest='title', type=str, default='', help='Text to include in graph title')
    parser.add_argument('--xlabel', dest='xlabel', type=str)
    parser.add_argument('--bins', dest='bins', type=int, default=10)
    parser.add_argument('--left', dest='left', type=int, default=0)
    parser.add_argument('--right', dest='right', type=int, default=None)
    return parser.parse_args()

def main():
    args = parse_args()

    df = pd.read_csv(args.metrics_file)
    df_metrics = calculate_metrics(df)
    generate_frequency_graph(df_metrics, args.metric, args.output_name, args.title, args.xlabel, args.bins, args.left, args.right)

if __name__ == '__main__':
    main()