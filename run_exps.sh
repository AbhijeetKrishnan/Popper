#!/bin/bash

# Learn tactics

## T-none
python popper.py chess \
      --eval-timeout 1 --tactic-file tactics/data/hspace/hspace_tactics_none.txt --precision-bound 0.0 --recall-bound 0.0

## T-prec
python popper.py chess \
      --eval-timeout 1 --tactic-file tactics/data/hspace/hspace_tactics_prec.txt --precision-bound 0.1 --recall-bound 0.0

## T-rec
python popper.py chess \
      --eval-timeout 1 --tactic-file tactics/data/hspace/hspace_tactics_rec.txt --precision-bound 0.0 --recall-bound 0.1

## T-all
python popper.py chess \
      --eval-timeout 1 --tactic-file tactics/data/hspace/hspace_tactics_all.txt --precision-bound 0.1 --recall-bound 0.1

# Calculate metrics

## T-none
python tactics/metrics.py tactics/data/hspace/hspace_tactics_none.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t_m1600_none.csv  \
      --engine MAIA1600 --eval-timeout 1
python tactics/metrics.py tactics/data/hspace/hspace_tactics_none.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t_sf14_none.csv   \
      --engine STOCKFISH_14 --eval-timeout 1

## T-prec
python tactics/metrics.py tactics/data/hspace/hspace_tactics_prec.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t_m1600_prec.csv  \
      --engine MAIA1600 --eval-timeout 1
python tactics/metrics.py tactics/data/hspace/hspace_tactics_prec.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t_sf14_prec.csv   \
      --engine STOCKFISH_14 --eval-timeout 1

## T-rec
python tactics/metrics.py tactics/data/hspace/hspace_tactics_rec.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t_m1600_rec.csv  \
      --engine MAIA1600 --eval-timeout 1
python tactics/metrics.py tactics/data/hspace/hspace_tactics_rec.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t_sf14_rec.csv   \
      --engine STOCKFISH_14 --eval-timeout 1

## T-all
python tactics/metrics.py tactics/data/hspace/hspace_tactics_all.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t_m1600_all.csv  \
      --engine MAIA1600 --eval-timeout 1
python tactics/metrics.py tactics/data/hspace/hspace_tactics_all.txt \
      --pos-list tactics/data/exs/examples_test.csv                \
      --data-path tactics/data/stats/metrics_test_t_sf14_all.csv   \
      --engine STOCKFISH_14 --eval-timeout 1