#!/bin/bash
for i in `seq 1 60`;
do
    cmd='nohup perl computeCorrTableParallel.pl ../data/uniref50.dat 60 '$i' &'
    echo $cmd
done 
