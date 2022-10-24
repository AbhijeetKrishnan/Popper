# Interpretable Chess Tactics

This is the code release for the paper *Synthesizing Chess Tactics from Player Games* by Abhijeet Krishnan and Dr. Chris Martens.

*Execution times are from executing the commands on Ubuntu 20.04 LTS via WSL2 on Windows 11 running on a Dell XPS 15 7590 with an Intel Core i7-9750H CPU @ 2.60GHz*

## Prerequisites

1. Install [Python v3.10.4](https://www.python.org/downloads/)

2. Clone the repository locally

   ```bash
   git clone https://github.com/AbhijeetKrishnan/interpretable-chess-tactics.git
   ```

3. Install the necessary Python dependencies

   ```bash
   pip install -r requirements.txt
   ```

4. Navigate to the root folder of the cloned repository

   ```bash
   mv interpretable-chess-tactics
   ```

5. Create the data directory structure assumed in the rest of the project

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

6. Run the `get_pgns.sh` script to download, unzip and move the games database files to the necessary locations

   ```bash
   bash get_pgns.sh
   ```

7. Generate data for the training and validation datasets (~14s)

   ```bash
   python tactics/gen_exs.py tactics/data/exs/examples.csv  \
      -i tactics/data/lichess_db_standard_rated_2013-01.pgn \
      -n 200 -p 1 --seed 1
   ```

8. Split the examples into training and validation sets

   ```bash
   python tactics/generate_train_valid.py tactics/data/exs/examples.csv \
      --trim=100 --split=100
   ```

9. Generate test data (~8s)

   ```bash
   python tactics/gen_exs.py tactics/data/exs/examples_test.csv \
      -i tactics/data/lichess_db_standard_rated_2013-02.pgn     \
      -n 20 -p 1 --seed 1
   ```

10. Trim the test data down to 10 test examples

   ```bash
   python tactics/generate_train_valid.py tactics/data/exs/examples_test.csv \
      --trim=10 --test
   ```

## Engine(s)

11. Download the latest x64 Stockfish 14 binary for Linux from the [Stockfish Downloads page](https://stockfishchess.org/files/stockfish_14_linux_x64.zip) and move the binary named
   `stockfish_14_x64` into the `tactics/bin/` folder

   ```bash
   wget https://stockfishchess.org/files/stockfish_14_linux_x64.zip
   unzip stockfish_14_linux_x64.zip
   mv stockfish_14_linux_x64/stockfish_14_x64 tactics/bin
   ```

12. Give execution permission to the Stockfish binary 

   ```bash
   chmod +x tactics/bin/stockfish_14_x64
   ```

13. Clone the `maia-chess` and `lc0` submodules

   ```bash
   git submodule init
   git submodule update
   ```

14. Build the `lc0` source code (~1m9s). Build instructions can be found in the [project README](https://github.com/LeelaChessZero/lc0/blob/master/README.md)

15. Unzip the Maia-Chess weights for ELO 1600 and move it outside the `maia-chess` submodule into a `maia_weights` folder

   ```bash
   gzip -dk tactics/bin/maia-chess/maia_weights/maia-1600.pb.gz
   mkdir tactics/bin/maia_weights
   mv tactics/bin/maia-chess/maia_weights/maia-1600.pb \
      tactics/bin/maia_weights
   ```

## Running the experiments

16. Learn tactics (~36m15s, 837 tactics)

   ```bash
   python popper.py chess --ex-file tactics/data/exs/examples_train.csv \
      --eval-timeout 1 > tactics/data/hspace/hspace_tactics.txt
   ```

17. Generate Maia-1600 validation stats (~22m23s)

   ```bash
   python tactics/metrics.py tactics/data/hspace/hspace_tactics.txt \
      --pos-list tactics/data/exs/examples_valid.csv                \
      --data-path tactics/data/stats/metrics_valid_maia1600.csv     \
      --engine MAIA1600
   ```

18. Obtain $T_{1600}$ ~~by filtering out the top-10% of tactics evaluated by Maia-1600~~

   ```bash
   python tactics/analysis.py tactics/data/stats/metrics_valid_maia1600.csv \
      -o tactics/data/hspace/hspace_t_1600.txt
   ```

19. Generate Stockfish 14 validation stats (~11m42s)

   ```bash
   python tactics/metrics.py tactics/data/hspace/hspace_tactics.txt \
      --pos-list tactics/data/exs/examples_valid.csv                \
      --data-path tactics/data/stats/metrics_valid_sf14.csv
   ```

20. Obtain $T_{SF}$ ~~by filtering out the top-10% of tactics evaluated by Stockfish 14~~

   ```bash
   python tactics/analysis.py tactics/data/stats/metrics_valid_sf14.csv \
      -o tactics/data/hspace/hspace_t_sf.txt
   ```

21. Measure difference between $T_{1600}$ and $T_{SF}$ (0 lines differed)

   ```bash
   diff -y --suppress-common-lines <(sort tactics/data/hspace/hspace_t_1600.txt) <(sort tactics/data/hspace/hspace_t_sf.txt) | wc -l
   ```

22. Evaluate $T_{1600}$ with Maia-1600 (~16m45s)

   ```bash
   python tactics/metrics.py tactics/data/hspace/hspace_t_1600.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t1600_m1600.csv  \
      --engine MAIA1600
   ```

23. Evaluate $T_{1600}$ with Stockfish 14 (~14m34s)
   
   ```bash
   python tactics/metrics.py tactics/data/hspace/hspace_t_1600.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t1600_sf14.csv   \
      --engine STOCKFISH
   ```

<!-- 24. Evaluate $T_{SF}$ with Maia-1600 (~19s)

   ```bash
   python tactics/metrics.py tactics/data/hspace/hspace_t_sf.txt \
      --pos-list tactics/data/exs/examples_test.csv              \
      --data-path tactics/data/stats/metrics_test_tsf_m1600.csv  \
      --engine MAIA1600
   ```

25. Evaluate $T_{SF}$ with Stockfish 14 (~15s)

   ```bash
   python tactics/metrics.py tactics/data/hspace/hspace_t_sf.txt \
      --pos-list tactics/data/exs/examples_test.csv              \
      --data-path tactics/data/stats/metrics_test_tsf_sf14.csv   \
      --engine STOCKFISH
   ``` -->

## Generate graphs

26. Run `gen_graphs.sh` to generate all graphs reported in the paper (~9s)

   ```bash
   bash gen_graphs.sh
   ```