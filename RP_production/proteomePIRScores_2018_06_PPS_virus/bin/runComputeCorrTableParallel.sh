#!/bin/bash
for i in `seq 1 64`;
do
    cmd='nohup perl computeCorrTableParallel.pl ../data/uniref50.dat 64 '$i' &'
    echo $cmd
done 
