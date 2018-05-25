#!/bin/bash

PROTOCOLS="DSR AODV DSDV"
NODES_START=5
NODES_STEP=5
NODES_END=50
TRYS=5

# using awk as bash doesn't support floating arithmetic
function math { awk "BEGIN { print $1 }"; }

rm -rf ./tmp
rm -rf ./res

mkdir -p ./tmp
mkdir -p ./res
mkdir -p ./res/trys

L="----------"
AVG_N_COUNT=$(math "(($NODES_END - $NODES_START) / $NODES_STEP ) + 1")

SECONDS=0

echo -e "Nodes Delay Throughput PDR\n" > ./res/all
echo "Protocol Delay Throughput PDR" > ./res/avg

for P in $PROTOCOLS; do
    NAME_RES="./res/$P"
    DLY_AVG_N=0
    THR_AVG_N=0
    PDR_AVG_N=0
    for i in $(seq $NODES_START $NODES_STEP $NODES_END); do
	      NAME="${P}_$i"
	      NAME_TCL="./tmp/$NAME.tcl"
	      NAME_TR="./tmp/$NAME.tr"
	      echo "set PROTO $P" > $NAME_TCL
	      echo "set NODES $i" >> $NAME_TCL
	      cat sim.tcl >> $NAME_TCL
        DLY_AVG=0
        THR_AVG=0
        PDR_AVG=0
        NAME_TRYS="./res/trys/$NAME"
        touch $NAME_TRYS
        for t in $(seq 1 $TRYS); do
            echo -e "\n$L RUNNING: $P, $i/$NODES_END nodes, $t/$TRYS trys $L\n"
	          ns $NAME_TCL
            DLY=$(awk -f delay.awk $NAME_TR)
            THR=$(awk -f throughput.awk $NAME_TR)
            PDR=$(awk -f pdr.awk $NAME_TR)
            DLY_AVG=$(math "$DLY_AVG + $DLY")
            THR_AVG=$(math "$THR_AVG + $THR")
            PDR_AVG=$(math "$PDR_AVG + $PDR")
	          echo "$DLY $THR $PDR" >> $NAME_TRYS
        done
        DLY_AVG=$(math "$DLY_AVG / $TRYS")
        THR_AVG=$(math "$THR_AVG / $TRYS")
        PDR_AVG=$(math "$PDR_AVG / $TRYS")
        touch $NAME_RES
        echo "$i $DLY_AVG $THR_AVG $PDR_AVG" >> $NAME_RES
        DLY_AVG_N=$(math "$DLY_AVG_N + $DLY_AVG")
        THR_AVG_N=$(math "$THR_AVG_N + $THR_AVG")
        PDR_AVG_N=$(math "$PDR_AVG_N + $PDR_AVG")
    done
    DLY_AVG_N=$(math "$DLY_AVG_N / $AVG_N_COUNT")
    THR_AVG_N=$(math "$THR_AVG_N / $AVG_N_COUNT")
    PDR_AVG_N=$(math "$PDR_AVG_N / $AVG_N_COUNT")
    echo "$P $DLY_AVG_N $THR_AVG_N $PDR_AVG_N" >> ./res/avg
    echo "$P $L" >> ./res/all
    cat $NAME_RES >> ./res/all
    echo >> ./res/all
done

cd res
../gen-graphs.gp

echo -e "\n$L DONE!!! $L\n"
duration=$SECONDS
echo "$(($duration / 60)) minute(s) and $(($duration % 60)) second(s) elapsed."

