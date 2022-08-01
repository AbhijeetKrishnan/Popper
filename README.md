# Interpretable Chess Tactics

## Dataset

1. Download Lichess games database for [2013 -
   January](https://database.lichess.org/standard/lichess_db_standard_rated_2013-01.pgn.bz2) from
   the [lichess.org open database](https://database.lichess.org/)

2. Unzip the games using `bzip2 -dk lichess_db_standard_rated_2013-01.pgn.bz2` and move into `data/` (create the
   folder if necessary)

```bash
mkdir data
bzip2 -dk lichess_db_standard_rated_2013-01.pgn.bz2
mv lichess_db_standard_rated_2013-01.pgn data
```

3. Generate train/valid data

```bash
python tactics/gen_exs.py tactics/data/exs/examples_train.csv -i tactics/data/lichess_db_standard_rated_2013-01.pgn -n 200 -p 1 -r 0 --middle-game-cutoff 10 --seed 1
```

4. Split into train/valid sets manually and trim it down to 100 validation examples TODO: do it via script

5. Generate test data

```bash
python tactics/gen_exs.py tactics/data/exs/examples_test.csv -i tactics/data/lichess_db_standard_rated_2013-02.pgn -n 1100 -p 1 -r 0 --middle-game-cutoff 10 --seed 1
```

6. Manually trim the test data down to 1000 test examples TODO: do it via script

## Engine(s)

7. Download the latest x64 Stockfish binary for Linux from the [Stockfish Downloads page]
   (https://stockfishchess.org/files/stockfish_14_linux_x64.zip) and move the binary named
   `stockfish_14_x64` into the `bin/` folder (create the folder if necessary)

```bash
mkdir bin
mv stockfish_14_x64 bin
```

8. Give execution permissions to the Stockfish binary using `chmod +x stockfish_14_x64`

9. Download the Maia-chess weights, unzip them and move them outside the maia-chess submodule into a `maia_weights` folder (create the folder if necessary)

```bash
cd maia-chess/maia_weights
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

13. Filter T_1600 TODO: write the commands for these

14. Filter T_SF

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

## Generate graphs TODO: write the commands for this