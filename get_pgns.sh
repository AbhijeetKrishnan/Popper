# Download the pgn zip files from Lichess
wget https://database.lichess.org/standard/lichess_db_standard_rated_2013-01.pgn.bz2
wget https://database.lichess.org/standard/lichess_db_standard_rated_2013-02.pgn.bz2

# Unzip them
bzip2 -dk lichess_db_standard_rated_2013-01.pgn.bz2
bzip2 -dk lichess_db_standard_rated_2013-02.pgn.bz2

# Move the pgn files to tactics/data
mv lichess_db_standard_rated_2013-01.pgn tactics/data
mv lichess_db_standard_rated_2013-02.pgn tactics/data

# Clean-up
rm lichess_db_standard_rated_2013-01.pgn.bz2
rm lichess_db_standard_rated_2013-02.pgn.bz2