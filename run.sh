#!/bin/bash

PROTOCOLS="DSR AODV DSDV"
NODES_START=$1 #5
NODES_STEP=$2 #2
NODES_END=$3 #50
TRYS=$4 #20

# using awk as bash doesn't support floating arithmetic
function math { awk "BEGIN { print $1 }"; }

HERE="$(pwd)"
DIR_NAME="${HERE}/out/${NODES_START}_${NODES_STEP}_${NODES_END}_${TRYS}"
RES_DIR="$DIR_NAME/res"
TMP_DIR="$DIR_NAME/tmp"

rm -rf "$TMP_DIR"
rm -rf "$RES_DIR"

mkdir -p "$TMP_DIR"
mkdir -p "$RES_DIR"
mkdir -p "$RES_DIR/trys"

L="----------"
AVG_N_COUNT=$(math "(($NODES_END - $NODES_START) / $NODES_STEP ) + 1")

SECONDS=0

echo -e "Nodes Delay Throughput PDR\n" > "$RES_DIR/all"
echo "Protocol Delay Throughput PDR" > "$RES_DIR/avg"

for P in $PROTOCOLS; do
    NAME_RES="$RES_DIR/$P"
    DLY_AVG_N=0
    THR_AVG_N=0
    PDR_AVG_N=0
    for i in $(seq $NODES_START $NODES_STEP $NODES_END); do
	      NAME="${P}_$i"
	      NAME_TCL="$TMP_DIR/$NAME.tcl"
	      NAME_TR="$TMP_DIR/$NAME.tr"
	      echo "set PROTO $P" > "$NAME_TCL"
	      echo "set NODES $i" >> "$NAME_TCL"
        echo "set DIR_NAME \"$TMP_DIR\"" >> "$NAME_TCL"
	      cat "$HERE/sim.tcl" >> "$NAME_TCL"
        DLY_AVG=0
        THR_AVG=0
        PDR_AVG=0
        NAME_TRYS="$RES_DIR/trys/$NAME"
        touch "$NAME_TRYS"
        for t in $(seq 1 $TRYS); do
            echo -e "\n$L RUNNING: $P, $i/$NODES_END nodes, $t/$TRYS trys $L\n"
	          ns "$NAME_TCL"
            DLY=$(awk -f "$HERE/delay.awk" "$NAME_TR")
            THR=$(awk -f "$HERE/throughput.awk" "$NAME_TR")
            PDR=$(awk -f "$HERE/pdr.awk" "$NAME_TR")
            DLY_AVG=$(math "$DLY_AVG + $DLY")
            THR_AVG=$(math "$THR_AVG + $THR")
            PDR_AVG=$(math "$PDR_AVG + $PDR")
	          echo "$DLY $THR $PDR" >> "$NAME_TRYS"
        done
        DLY_AVG=$(math "$DLY_AVG / $TRYS")
        THR_AVG=$(math "$THR_AVG / $TRYS")
        PDR_AVG=$(math "$PDR_AVG / $TRYS")
        touch "$NAME_RES"
        echo "$i $DLY_AVG $THR_AVG $PDR_AVG" >> "$NAME_RES"
        DLY_AVG_N=$(math "$DLY_AVG_N + $DLY_AVG")
        THR_AVG_N=$(math "$THR_AVG_N + $THR_AVG")
        PDR_AVG_N=$(math "$PDR_AVG_N + $PDR_AVG")
    done
    DLY_AVG_N=$(math "$DLY_AVG_N / $AVG_N_COUNT")
    THR_AVG_N=$(math "$THR_AVG_N / $AVG_N_COUNT")
    PDR_AVG_N=$(math "$PDR_AVG_N / $AVG_N_COUNT")
    echo "$P $DLY_AVG_N $THR_AVG_N $PDR_AVG_N" >> "$RES_DIR/avg"
    echo "$P $L" >> "$RES_DIR/all"
    cat "$NAME_RES" >> "$RES_DIR/all"
    echo >> "$RES_DIR/all"
done

cd "$RES_DIR"
"$HERE/gen-graphs.gp"

echo -e "\n$L DONE!!! $L\n"
duration=$SECONDS
echo "$(($duration / 60)) minute(s) and $(($duration % 60)) second(s) elapsed."

