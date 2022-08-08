#!/usr/bin/env python3

import argparse
import csv
import logging
import os
from typing import List

logger = logging.getLogger(__name__)

def read_examples(examples_file: str) -> List:
    "Read examples file and output list of examples"
    with open(examples_file) as csvfile:
        reader = csv.DictReader(csvfile)
        return list(reader)

def write_examples(examples_file: str, examples_list: List[dict]) -> None:
    with open(examples_file, 'w') as csvfile:
        field_names = ['fen', 'uci', 'label']
        writer = csv.DictWriter(csvfile, fieldnames=field_names)
        writer.writeheader()
        for ex in examples_list:
            writer.writerow(ex)

def parse_args():
    parser = argparse.ArgumentParser(description='Split input examples into test/valid')
    parser.add_argument('examples_file', type=str, help='file containing list of examples')
    parser.add_argument('--log', dest='log_level', choices=['DEBUG', 'INFO', 'WARNING', 'ERROR'], help='Set the logging level', default='INFO')
    parser.add_argument('--trim', dest='trim_limit', type=int, default=None, help='Trim down the input examples to this before splitting')
    parser.add_argument('--split', dest='train_pct', type=int, default=20, help='Percentage of examples to include in train dataset')
    parser.add_argument('--test', dest='test', action='store_true', default=False, help='Flag for indicating that input is list of test examples to be trimmed')
    return parser.parse_args()

def main():
    args = parse_args()

    # read example file
    examples = read_examples(args.examples_file)
    base_dir = os.path.dirname(os.path.abspath(args.examples_file))

    # trim examples
    if args.trim_limit:
        trimmed_examples = examples[:args.trim_limit]
    else:
        trimmed_examples = examples

    if args.test:
        write_examples(os.path.join(base_dir, 'examples_test.csv'), trimmed_examples)
        return

    # split into train/valid
    train_size = int(len(trimmed_examples) * (args.train_pct / 100))
    train_examples, valid_examples = trimmed_examples[:train_size], trimmed_examples[train_size:]

    # write examples to file
    base_dir = os.path.dirname(os.path.abspath(args.examples_file))
    write_examples(os.path.join(base_dir, 'examples_train.csv'), train_examples)
    if valid_examples:
        write_examples(os.path.join(base_dir, 'examples_valid.csv'), valid_examples)
    

if __name__ == '__main__':
    main()