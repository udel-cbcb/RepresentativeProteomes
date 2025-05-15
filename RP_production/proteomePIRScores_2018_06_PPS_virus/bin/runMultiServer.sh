rm ../out/*
perl computeProteomeCorrTableMultiServersHashMin.pl 4 1 ../data ../logs ../out > ../logs/run_server_1.log &
perl computeProteomeCorrTableMultiServersHashMin.pl 4 2 ../data ../logs ../out > ../logs/run_server_2.log &
perl computeProteomeCorrTableMultiServersHashMin.pl 4 3 ../data ../logs ../out > ../logs/run_server_3.log &
perl computeProteomeCorrTableMultiServersHashMin.pl 4 4 ../data ../logs ../out > ../logs/run_server_4.log &


