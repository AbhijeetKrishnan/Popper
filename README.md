# Interpretable Chess Tactics

This is the code release for the paper *Inductive Logic Programming for Chess Strategy Synthesis from Player Trajectories* under review at IJCAI 2023 by Abhijeet Krishnan, Dr. Chris Martens and Dr. Arnav Jhala.

*Execution times are from executing the commands on Ubuntu 20.04 LTS via WSL2 on Windows 11 running on a Dell XPS 15 7590 with an Intel Core i7-9750H CPU @ 2.60GHz*

## Prerequisites

1. Install [Python v3.10.4](https://www.python.org/downloads/)

1. Clone the repository locally

   ```bash
   git clone --recurse-submodules -j 8 https://github.com/AbhijeetKrishnan/interpretable-chess-tactics.git
   ```

1. Install the necessary Python dependencies

   ```bash
   python3 -m pip install -r requirements.txt
   ```

1. Navigate to the root folder of the cloned repository

   ```bash
   mv interpretable-chess-tactics
   ```

1. Create the data directory structure assumed in the rest of the project

   ```bash
   mkdir tactics/data
   mkdir tactics/data/exs \
      tactics/data/hspace \
      tactics/data/stats  \
      tactics/data/graphs
   ```

## Dataset

We use Lichess games databases for [2013 -
   January](https://database.lichess.org/standard/lichess_db_standard_rated_2013-01.pgn.bz2) and [2013 - February](https://database.lichess.org/standard/lichess_db_standard_rated_2013-02.pgn.bz2) from
   the [lichess.org open database](https://database.lichess.org/) for our train/validation and test datasets respectively. 

1. Run the `get_pgns.sh` script to download, unzip and move the games database files to the necessary locations

   ```bash
   bash get_pgns.sh
   ```

1. Generate train dataset (~11s)

   ```bash
   python tactics/gen_exs.py chess/exs.pl  \
      -i tactics/data/lichess_db_standard_rated_2013-01.pgn \
      -n 500 -p 1 --seed 1 --use-engine
   ```

<!-- 8. Split the examples into training ~~and validation~~ sets

   ```bash
   python tactics/generate_train_valid.py tactics/data/exs/examples.csv \
      --trim=100 --split=100
   ``` -->

1. Generate test dataset (~7s)

   ```bash
   python tactics/gen_exs.py tactics/data/exs/examples_test.csv \
      -i tactics/data/lichess_db_standard_rated_2013-02.pgn     \
      -n 100 -p 1 --seed 1
   ```

1. Trim the test data down to 100 test examples

   ```bash
   python tactics/generate_train_valid.py tactics/data/exs/examples_test.csv \
      --trim=100 --test
   ```

## Engine(s)

1. Download the latest x64 Stockfish 15 binary for Linux from the [Stockfish Downloads page](https://stockfishchess.org/files/stockfish_15.1_linux_x64_avx2.zip) and move the binary named
   `stockfish-ubuntu-20.04-x86-64-avx2` into the `tactics/bin/` folder. Delete any leftover files manually.

   ```bash
   wget https://stockfishchess.org/files/stockfish_15.1_linux_x64_avx2.zip
   unzip stockfish_15.1_linux_x64_avx2.zip
   mv stockfish_15.1_linux_x64_avx2/stockfish-ubuntu-20.04-x86-64-avx2 tactics/bin
   ```

1. Give execution permission to the Stockfish binary 

   ```bash
   chmod +x tactics/bin/stockfish-ubuntu-20.04-x86-64-avx2
   ```

1. Build the `lc0` source code (~1m9s). Build instructions can be found in the [project README](https://github.com/LeelaChessZero/lc0/blob/master/README.md)

1. Unzip the Maia-Chess weights for ELO 1600 and move it outside the `maia-chess` submodule into a `maia_weights` folder

   ```bash
   gzip -dk tactics/bin/maia-chess/maia_weights/maia-1600.pb.gz
   mkdir tactics/bin/maia_weights
   mv tactics/bin/maia-chess/maia_weights/maia-1600.pb \
      tactics/bin/maia_weights
   ```

## Running the experiments

1. Learn tactics (~10m7s, 73 tactics)

   ```bash
   python popper.py chess \
      --eval-timeout 1 --tactic-file tactics/data/hspace/hspace_tactics.txt
   ```

1. Evaluate $T$ with Maia-1600 (~6s)

   ```bash
   python tactics/metrics.py tactics/data/hspace/hspace_tactics.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t_m1600.csv  \
      --engine MAIA1600 --eval-timeout 1
   ```

1. Evaluate $T$ with Stockfish 15 (~3s)
   
   ```bash
   python tactics/metrics.py tactics/data/hspace/hspace_tactics.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t_sf.csv   \
      --engine STOCKFISH --eval-timeout 1
   ```

## Generate graphs

1. Run `gen_graphs.sh` to generate all graphs reported in the paper (~5s)

   ```bash
   bash gen_graphs.sh
   ```
