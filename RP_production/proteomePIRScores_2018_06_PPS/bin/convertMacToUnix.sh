#!/bin/bash
EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
        echo "Usage: sh `basename $0` macText unixText"
                exit $E_BADARGS
                fi

awk '{gsub("\r", "\n"); print $0;}' $1 > $2 
