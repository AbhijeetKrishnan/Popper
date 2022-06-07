# Interpretable Chess Tactics

1. Download Lichess games database for [2013 -
   January](https://database.lichess.org/standard/lichess_db_standard_rated_2013-01.pgn.bz2) from
   the [lichess.org open database](https://database.lichess.org/)
2. Unzip using `bzip2 -dk lichess_db_standard_rated_2013-01.pgn.bz2` and move into `data/` (create
   folder if necessary)
3. Generate `requirements.txt` using `pip freeze > requirements.txt`
4. Download the latest x64 Stockfish binary for Linux from the [Stockfish Downloads page]
   (https://stockfishchess.org/files/stockfish_14_linux_x64.zip) and move the binary named
   `stockfish_14_x64` into the `bin/` folder (create folder if necessary)
5. Give execution permissions to the Stockfish binary using `chmod +x stockfish_14_x64`
6. Run the Jupyter notebook

Download the maia-chess weights and unzip them

Generate train/valid data
`python tactics/gen_exs.py tactics/data/exs/examples_train.csv -i tactics/data/lichess_db_standard_rated_2013-01.pgn -n 200 -p 1 -r 0 --middle-game-cutoff 10 --seed 1`

split into train/valid sets manually and trim to 100 validation examples

Generate test data
`python tactics/gen_exs.py tactics/data/exs/examples_test.csv -i tactics/data/lichess_db_standard_rated_2013-02.pgn -n 1100 -p 1 -r 0 --middle-game-cutoff 10 --seed 1`

manually trim to 1000 test examples

Learn tactics (~7 min)
`python popper.py chess --ex-file tactics/data/exs/examples_train.csv --eval-timeout 1 > tactics/data/hspace/hspace_tactics.txt`

Generate Maia-1600 validation stats (~50 min)
`python tactics/metrics.py tactics/data/hspace/hspace_tactics.txt --pos-list tactics/data/exs/examples_valid.csv --data-path tactics/data/stats/metrics_valid_maia1600.csv --engine MAIA1600`

Generate Stockfish 14 validation stats (~35 mins)
`python tactics/metrics.py tactics/data/hspace/hspace_tactics.txt --pos-list tactics/data/exs/examples_valid.csv --data-path tactics/data/stats/metrics_valid_sf14.csv`

Filter T_1600

Filter T_SF

Evaluate T1600 with M1600 (~2.5 hrs), SF14
`python tactics/metrics.py tactics/data/hspace/hspace_t_1600.txt --pos-list tactics/data/exs/examples_test.csv --data-path tactics/data/stats/metrics_test_t1600_m1600.csv --engine MAIA1600`
`python tactics/metrics.py tactics/data/hspace/hspace_t_1600.txt --pos-list tactics/data/exs/examples_test.csv --data-path tactics/data/stats/metrics_test_t1600_sf14.csv --engine STOCKFISH`

Evaluate T_SF with M1600, SF14
`python tactics/metrics.py tactics/data/hspace/hspace_t_sf.txt --pos-list tactics/data/exs/examples_test.csv --data-path tactics/data/stats/metrics_test_tsf_m1600.csv --engine MAIA1600`
`python tactics/metrics.py tactics/data/hspace/hspace_t_sf.txt --pos-list tactics/data/exs/examples_test.csv --data-path tactics/data/stats/metrics_test_tsf_sf14.csv --engine STOCKFISH`