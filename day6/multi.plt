set term pngcairo font "Helvetica,18"
set out "multi.png"
set xla "# of procs"
set yla "Elapsed time [ms]"
set log x
set xra [18:]
set yra [0:]
set xtics (18,36,72,108,144,216,432)
p "multi.dat" u 1:3 w linespoints pt 7 t ""

