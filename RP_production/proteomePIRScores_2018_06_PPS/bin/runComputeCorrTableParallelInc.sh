#!/bin/bash
for i in `seq 1 48`;
do
    cmd='nohup perl computeCorrTableParallelInc.pl ../data/uniref50.dat 48 '$i' &'
    echo $cmd
done 
