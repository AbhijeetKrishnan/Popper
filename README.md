# Interpretable Chess Tactics

This is the code release for the paper *Synthesizing Chess Tactics from Player Games* by Abhijeet Krishnan and Dr. Chris Martens.

The bash commands below assume you are in the root folder of the repository.

## Dataset

1. Download Lichess games database for [2013 -
   January](https://database.lichess.org/standard/lichess_db_standard_rated_2013-01.pgn.bz2) from
   the [lichess.org open database](https://database.lichess.org/)

2. Unzip the games and move them into `tactics/data/` (create the folder if necessary)

```bash
mkdir tactics/data
bzip2 -dk path/to/lichess_db_standard_rated_2013-01.pgn.bz2
mv path/to/lichess_db_standard_rated_2013-01.pgn tactics/data
```

3. Generate data for the training and validation datasets

```bash
python tactics/gen_exs.py tactics/data/exs/examples.csv -i tactics/data/lichess_db_standard_rated_2013-01.pgn -n 200 -p 1 -r 0 --middle-game-cutoff 10 --seed 1
```

4. Split the examples into training and validation sets

```bash
python tactics/generate_train_valid.py tactics/data/exs/examples.csv --trim=100 --split=20
```

5. Generate test data

```bash
python tactics/gen_exs.py tactics/data/exs/examples_test.csv -i tactics/data/lichess_db_standard_rated_2013-02.pgn -n 1100 -p 1 -r 0 --middle-game-cutoff 10 --seed 1
```

6. Trim the test data down to 1000 test examples

```bash
python tactics/generate_train_valid.py tactics/data/exs/examples_test.csv --trim=1000 --test
```

## Engine(s)

7. Download the latest x64 Stockfish binary for Linux from the [Stockfish Downloads page](https://stockfishchess.org/files/stockfish_14_linux_x64.zip) and move the binary named
   `stockfish_14_x64` into the `tactics/bin/` folder (create the folder if necessary)

```bash
mkdir bin
mv path/to/stockfish_14_x64 tactics/bin
```

8. Give execution permission to the Stockfish binary 

```bash
chmod +x tactics/bin/stockfish_14_x64
```

9. Download the Maia-Chess weights, unzip them and move them outside the `maia-chess` submodule into a `maia_weights` folder (create the folder if necessary)

```bash
cd tactics/bin/maia-chess/maia_weights
gzip -d maia-1100.pb.gz
gzip -d maia-1600.pb.gz
mkdir ../maia_weights
mv maia-1100.pb maia-1600.pb ../maia_weights
```

## Running the experiments

10. Learn tactics (~7 min)

```bash
python popper.py chess --ex-file tactics/data/exs/examples_train.csv --eval-timeout 1 > tactics/data/hspace/hspace_tactics.txt
```

11. Generate Maia-1600 validation stats (~50 min)

```bash
python tactics/metrics.py tactics/data/hspace/hspace_tactics.txt --pos-list tactics/data/exs/examples_valid.csv --data-path tactics/data/stats/metrics_valid_maia1600.csv --engine MAIA1600
```

12. Generate Stockfish 14 validation stats (~35 mins)

```bash
python tactics/metrics.py tactics/data/hspace/hspace_tactics.txt --pos-list tactics/data/exs/examples_valid.csv --data-path tactics/data/stats/metrics_valid_sf14.csv
```

13. Filter T_1600 to obtain the top-10% of tactics

```bash
python tactics/analysis.py tactics/data/stats/metrics_valid_maia1600.csv -o tactics/data/hspace/hspace_t_1600.txt --filter 10
```

14. Filter T_SF to obtain the top-10% of tactics

```bash
python tactics/analysis.py tactics/data/stats/metrics_valid_sf14.csv -o tactics/data/hspace/hspace_t_sf.txt --filter 10
```

15. Evaluate T1600 with M1600 (~2.5 hrs), SF14

```bash
# T_1600 with Maia-1600
python tactics/metrics.py tactics/data/hspace/hspace_t_1600.txt --pos-list tactics/data/exs/examples_test.csv --data-path tactics/data/stats/metrics_test_t1600_m1600.csv --engine MAIA1600

# T_1600 with Stockfish 14
python tactics/metrics.py tactics/data/hspace/hspace_t_1600.txt --pos-list tactics/data/exs/examples_test.csv --data-path tactics/data/stats/metrics_test_t1600_sf14.csv --engine STOCKFISH
```

16. Evaluate T_SF with M1600, SF14

```bash
# T_SF with Maia-1600
python tactics/metrics.py tactics/data/hspace/hspace_t_sf.txt --pos-list tactics/data/exs/examples_test.csv --data-path tactics/data/stats/metrics_test_tsf_m1600.csv --engine MAIA1600

# T_SF with Stockfish 14
python tactics/metrics.py tactics/data/hspace/hspace_t_sf.txt --pos-list tactics/data/exs/examples_test.csv --data-path tactics/data/stats/metrics_test_tsf_sf14.csv --engine STOCKFISH
```

## Generate graphs

17. Open `analysis.ipynb`
18. Modify the variable `data_filename` to point to the input metric file
19. Modify the `plt.title` statements to reflect the current engine and tactic file being used
20. Run all cells to generate the graphs for divergence, accuracy and evaluation score
21. Download and save the graphs from the IPython viewer to `tactics/data/graphs`
22. Repeat for all test metrics generated