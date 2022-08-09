# Interpretable Chess Tactics

This is the code release for the paper *Synthesizing Chess Tactics from Player Games* by Abhijeet Krishnan and Dr. Chris Martens.

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

7. Generate data for the training and validation datasets (~12s)

   ```bash
   python tactics/gen_exs.py tactics/data/exs/examples.csv  \
      -i tactics/data/lichess_db_standard_rated_2013-01.pgn \
      -n 200 -p 1 -r 0 --middle-game-cutoff 10 --seed 1
   ```

8. Split the examples into training and validation sets

   ```bash
   python tactics/generate_train_valid.py tactics/data/exs/examples.csv \
      --trim=100 --split=20
   ```

9. Generate test data (~39s)

   ```bash
   python tactics/gen_exs.py tactics/data/exs/examples_test.csv \
      -i tactics/data/lichess_db_standard_rated_2013-02.pgn     \
      -n 1100 -p 1 -r 0 --middle-game-cutoff 10 --seed 1
   ```

10. Trim the test data down to 1000 test examples

   ```bash
   python tactics/generate_train_valid.py tactics/data/exs/examples_test.csv \
      --trim=1000 --test
   ```

## Engine(s)

11. Download the latest x64 Stockfish binary for Linux from the [Stockfish Downloads page](https://stockfishchess.org/files/stockfish_14_linux_x64.zip) and move the binary named
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

14. Download the Maia-Chess weights for ELO 1100 and 1600, unzip them and move them outside the `maia-chess` submodule into a `maia_weights` folder

   ```bash
   gzip -dk tactics/bin/maia-chess/maia_weights/maia-1100.pb.gz
   gzip -dk tactics/bin/maia-chess/maia_weights/maia-1600.pb.gz
   mkdir tactics/bin/maia_weights
   mv tactics/bin/maia-chess/maia_weights/maia-1100.pb \
      tactics/bin/maia-chess/maia_weights/maia-1600.pb \
      tactics/bin/maia_weights
   ```

## Running the experiments

15. Learn tactics (~7 min)

   ```bash
   python popper.py chess --ex-file tactics/data/exs/examples_train.csv \
      --eval-timeout 1 > tactics/data/hspace/hspace_tactics.txt
   ```

16. Generate Maia-1600 validation stats (~50 min)

   ```bash
   python tactics/metrics.py tactics/data/hspace/hspace_tactics.txt \
      --pos-list tactics/data/exs/examples_valid.csv                \
      --data-path tactics/data/stats/metrics_valid_maia1600.csv     \
      --engine MAIA1600
   ```

17. Generate Stockfish 14 validation stats (~35 mins)

   ```bash
   python tactics/metrics.py tactics/data/hspace/hspace_tactics.txt \
      --pos-list tactics/data/exs/examples_valid.csv                \
      --data-path tactics/data/stats/metrics_valid_sf14.csv
   ```

18. Filter T_1600 to obtain the top-10% of tactics

   ```bash
   python tactics/analysis.py tactics/data/stats/metrics_valid_maia1600.csv \
      -o tactics/data/hspace/hspace_t_1600.txt --filter 10
   ```

19. Filter T_SF to obtain the top-10% of tactics

   ```bash
   python tactics/analysis.py tactics/data/stats/metrics_valid_sf14.csv \
      -o tactics/data/hspace/hspace_t_sf.txt --filter 10
   ```

20. Evaluate T1600 with M1600 (~2.5 hrs), SF14

   ```bash
   # T_1600 with Maia-1600
   python tactics/metrics.py tactics/data/hspace/hspace_t_1600.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t1600_m1600.csv  \
      --engine MAIA1600

   # T_1600 with Stockfish 14
   python tactics/metrics.py tactics/data/hspace/hspace_t_1600.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t1600_sf14.csv   \
      --engine STOCKFISH
   ```

21. Evaluate T_SF with M1600, SF14

   ```bash
   # T_SF with Maia-1600
   python tactics/metrics.py tactics/data/hspace/hspace_t_sf.txt \
      --pos-list tactics/data/exs/examples_test.csv              \
      --data-path tactics/data/stats/metrics_test_tsf_m1600.csv  \
      --engine MAIA1600

   # T_SF with Stockfish 14
   python tactics/metrics.py tactics/data/hspace/hspace_t_sf.txt \
      --pos-list tactics/data/exs/examples_test.csv              \
      --data-path tactics/data/stats/metrics_test_tsf_sf14.csv   \
      --engine STOCKFISH
   ```

## Generate graphs

22. Open `analysis.ipynb`
23. Modify the variable `data_filename` to point to the input metric file
24. Modify the `plt.title` statements to reflect the current engine and tactic file being used
25. Run all cells to generate the graphs for divergence, accuracy and evaluation score
26. Download and save the graphs from the IPython viewer to `tactics/data/graphs`
27. Repeat for all test metrics generated