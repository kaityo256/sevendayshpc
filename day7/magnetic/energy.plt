set term pngcairo
set out "energy.png"

set style data linespoints
set xla "Time"
set yla "Energy"
set key bottom
set xtics 20
p [][0:] "euler.dat" t "1st-Euler" pt 6,"rk2.dat" t"2nd-RK" pt 7
