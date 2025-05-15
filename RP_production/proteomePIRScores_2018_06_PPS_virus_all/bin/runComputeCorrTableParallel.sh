#!/bin/bash
for i in `seq 1 48`;
do
    cmd='nohup perl computeCorrTableParallel.pl ../data/uniref50.dat 48 '$i' &'
    echo $cmd
done 
