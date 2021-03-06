#!/bin/gnuplot

set terminal png size 950,550
set grid

set style line 1 lc rgb '#3af800' lt 1 lw 2 pt 7 ps 1.5
set style line 2 lc rgb '#004586' lt 1 lw 2 pt 7 ps 1.5
set style line 3 lc rgb '#ff420e' lt 1 lw 2 pt 7 ps 1.5

set output 'delay.png'
set title 'Delay'
set ylabel 'Delay'
set xlabel 'Nodes'
plot 'DSR' using 1:2 with linespoints ls 1 title 'DSR', \
     'AODV' using 1:2 with linespoints ls 2 title 'AODV', \
          'DSDV' using 1:2 with linespoints ls 3 title 'DSDV'

set output 'throughput.png'
set title 'Throughput'
set ylabel 'Throughput'
set xlabel 'Nodes'
plot 'DSR' using 1:3 with linespoints ls 1 title 'DSR', \
     'AODV' using 1:3 with linespoints ls 2 title 'AODV', \
          'DSDV' using 1:3 with linespoints ls 3 title 'DSDV'

set output 'pdr.png'
set title 'PDR'
set ylabel 'PDR'
set xlabel 'Nodes'
plot 'DSR' using 1:4 with linespoints ls 1 title 'DSR', \
     'AODV' using 1:4 with linespoints ls 2 title 'AODV', \
          'DSDV' using 1:4 with linespoints ls 3 title 'DSDV'
