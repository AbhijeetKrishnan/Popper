# Divergence
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_t_m1600_new.csv -m avg_tactic_ground_avg -o tactics/data/graphs/divergence_t_m1600_new.pgf --title "Divergence \$(T,\$ Maia-1600, \$P_{test})\$" --xlabel "Divergence (Cp)" --left=-10
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_t_sf14_new.csv -m avg_tactic_ground_avg -o tactics/data/graphs/divergence_t_sf14_new.pgf --title "Divergence \$(T,\$ Stockfish 14, \$P_{test})\$" --xlabel "Divergence (Cp)" --left=-10
# python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_tsf_m1600.csv -m avg_tactic_ground_avg -o tactics/data/graphs/divergence_tsf_m1600.pgf --title "Divergence \$(T_{SF},\$ Maia-1600, \$P_{test})\$" --xlabel "Divergence (Cp)" --left=-10
# python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_tsf_sf.csv -m avg_tactic_ground_avg -o tactics/data/graphs/divergence_tsf_sf.pgf --title "Divergence \$(T_{SF},\$ Stockfish 14, \$P_{test})\$" --xlabel "Divergence (Cp)" --left=-10

# Coverage
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_t_m1600_new.csv -m coverage -o tactics/data/graphs/coverage_t_new.pgf --title "Coverage \$(T,\$ \$P_{test})\$" --xlabel "Coverage"
# python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_tsf_sf.csv -m coverage -o tactics/data/graphs/coverage_tsf.pgf --title "Coverage \$(T_{SF},\$ \$P_{test})\$" --xlabel "Coverage"

# Accuracy
python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_t_m1600_new.csv -m accuracy -o tactics/data/graphs/accuracy_t_new.pgf --title "Accuracy \$(T,\$ \$P_{test})\$" --xlabel "Accuracy" --left=-0.1 --right=1.1
# python3 tactics/generate_graphs.py tactics/data/stats/metrics_test_tsf_sf.csv -m accuracy -o tactics/data/graphs/accuracy_tsf.pgf --title "Accuracy \$(T_{SF},\$ \$P_{test})\$" --xlabel "Accuracy" --right=1.1