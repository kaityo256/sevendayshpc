set term pngcairo font "Helvetica,18"
set out "single.png"
set log xy
set xtics (1,2,4,6,8,12,24)
set xla "# of threads/procs"
set yla "Elapsed time [ms]"
set yra [500:13010]
p "single.dat" w linespoints pt 7 t "Thread"\
, "single.dat" u 1:3 w linespoints pt 6 t "Process"\
, 13000/x lc 0 lt 1 lw 1 t "Ideal"

set out "single_eff.png"
set yla "Efficiency [%]"
unset log y
set yra [0:100]
set key left bottom
p "single.dat" u 1:(13000/$2/$1*100) w linespoints pt 7 t "Thread"\
, "single.dat" u 1:(13000/$3/$1*100) w linespoints pt 6 t "Process"\
