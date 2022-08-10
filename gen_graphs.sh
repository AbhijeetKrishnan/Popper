# T_1600 + Maia-1600
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_t1600_m1600.csv -m avg_divergence -o tactics/data/graphs/t1600_m1600_divergence.png --title "Divergence \$(T_{1600},\$ Maia-1600, \$P_{test})\$" --xlabel "Divergence (Cp)"
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_t1600_m1600.csv -m coverage -o tactics/data/graphs/t1600_m1600_coverage.png --title "Coverage \$(T_{1600},\$ Maia-1600, \$P_{test})\$" --xlabel "Coverage"
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_t1600_m1600.csv -m accuracy -o tactics/data/graphs/t1600_m1600_accuracy.png --title "Accuracy \$(T_{1600},\$ Maia-1600, \$P_{test})\$" --xlabel "Accuracy"

# T_1600 + Stockfish 14
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_t1600_sf14.csv -m avg_divergence -o tactics/data/graphs/t1600_sf14_divergence.png --title "Divergence \$(T_{1600},\$ Stockfish 14, \$P_{test})\$" --xlabel "Divergence (Cp)"
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_t1600_sf14.csv -m coverage -o tactics/data/graphs/t1600_sf14_coverage.png --title "Coverage \$(T_{1600},\$ Stockfish 14, \$P_{test})\$" --xlabel "Coverage"
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_t1600_sf14.csv -m accuracy -o tactics/data/graphs/t1600_sf14_accuracy.png --title "Accuracy \$(T_{1600},\$ Stockfish 14, \$P_{test})\$" --xlabel "Accuracy"

# T_SF + Maia-1600
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_tsf_m1600.csv -m avg_divergence -o tactics/data/graphs/tsf_m1600_divergence.png --title "Divergence \$(T_{SF},\$ Maia-1600, \$P_{test})\$" --xlabel "Divergence (Cp)"
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_tsf_m1600.csv -m coverage -o tactics/data/graphs/tsf_m1600_coverage.png --title "Coverage \$(T_{SF},\$ Maia-1600, \$P_{test})\$" --xlabel "Coverage"
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_tsf_m1600.csv -m accuracy -o tactics/data/graphs/tsf_m1600_accuracy.png --title "Accuracy \$(T_{SF},\$ Maia-1600, \$P_{test})\$" --xlabel "Accuracy"

# T_SF + Stockfish 14
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_tsf_sf14.csv -m avg_divergence -o tactics/data/graphs/tsf_sf14_divergence.png --title "Divergence \$(T_{SF},\$ Stockfish 14, \$P_{test})\$" --xlabel "Divergence (Cp)"
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_tsf_sf14.csv -m coverage -o tactics/data/graphs/tsf_sf14_coverage.png --title "Coverage \$(T_{SF},\$ Stockfish 14, \$P_{test})\$" --xlabel "Coverage"
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_tsf_sf14.csv -m accuracy -o tactics/data/graphs/tsf_sf14_accuracy.png --title "Accuracy \$(T_{SF},\$ Stockfish 14, \$P_{test})\$" --xlabel "Accuracy"
