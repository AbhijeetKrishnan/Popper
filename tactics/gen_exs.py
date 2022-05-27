import argparse
import csv
import random
from typing import List, Optional, TextIO

import chess
import chess.engine
import chess.pgn

from util import LICHESS_2013, STOCKFISH, PathLike, get_engine, get_top_n_moves


def sample_pgn(handle: TextIO, num_games: int=10, pos_per_game: int=10) -> List[chess.Board]:
    "Sample positions from games in a PGN file"
    
    result = []
    rand_state = random.getstate()

    # obtain num_game offsets from list of games
    offsets = []
    while _ := chess.pgn.read_headers(handle) is not None:
        offset = handle.tell()
        offsets.append(offset)
    sampled_offsets = random.sample(offsets, num_games)

    # obtain pos_per_game positions from sampled list of games
    random.setstate(rand_state)
    for offset in sampled_offsets:
        handle.seek(offset)
        game = chess.pgn.read_game(handle)
        examples = []
        if game:
            node = game.next()
            while node and not node.is_end():
                board = node.parent.board()
                move = node.move
                examples.append((board, move))
                node = node.next()
            sampled_examples = random.sample(examples, pos_per_game)
            result.extend(sampled_examples)

    return result

def gen_exs(exs_pgn_path: PathLike, num_games: int=10, pos_per_game: int=10, neg_to_pos_ratio: int=0, use_engine: bool=False, engine_path: Optional[PathLike]=None):
    
    with open(exs_pgn_path) as handle:
        sample_examples = sample_pgn(handle, num_games=num_games, pos_per_game=pos_per_game)
    
    if use_engine:
        with get_engine(engine_path) as engine:
            for position, move in sample_examples:
                moves = get_top_n_moves(engine, position, neg_to_pos_ratio + 1)
                if not moves:
                    continue
                _, top_move = moves[0]
                yield {'fen': position.fen(), 'uci': top_move.uci(), 'label': 1}
                for _, move in moves[1:]:
                    yield {'fen': position.fen(), 'uci': move.uci(), 'label': 0}
    else:
        for position, move in sample_examples:
            yield {'fen': position.fen(), 'uci': move.uci(), 'label': 1}

def parse_args():
    parser = argparse.ArgumentParser(description='Generate tactic training examples and write them to a csv file')
    parser.add_argument('example_file', type=str, help='File to write generated examples to')
    parser.add_argument('-i', '--pgn', dest='pgn_file', type=str, default=LICHESS_2013, help='PGN file containing games')
    parser.add_argument('-e', '--engine', dest='engine_path', default=STOCKFISH, help='Path to engine executable to use for recommending moves')
    parser.add_argument('-n', '--num-games', dest='num_games', type=int, default=10, help='Number of games to use')
    parser.add_argument('-p', '--pos-per-game', dest='pos_per_game', type=int, default=10, help='Number of positions to use per game')
    parser.add_argument('-r', '--ratio', dest='neg_to_pos_ratio', type=int, default=3, help='Ratio of negative to positive examples to generate')
    parser.add_argument('--seed', dest='seed', type=int, default=1, help='Seed to use for random generation')
    parser.add_argument('--use-engine', action='store_true', help='Use engine to generate moves for the examples')
    return parser.parse_args()

def main():
    args = parse_args()
    random.seed(args.seed)

    with open(args.example_file, 'w') as output:
        field_names = ['fen', 'uci', 'label']
        writer = csv.DictWriter(output, fieldnames=field_names)
        writer.writeheader()
        for ex in gen_exs(args.pgn_file, args.num_games, args.pos_per_game, args.neg_to_pos_ratio, args.use_engine, args.engine_path):
            writer.writerow(ex)

if __name__ == '__main__':
    main()
