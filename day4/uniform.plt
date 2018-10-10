set term pngcairo
set xla "x"
set yla "T"
set out "uniform.png"
set xra[0:127]

p "data001.dat" w l t "t=200","data010.dat" w l t "t=200","data050.dat" w l t "t=1000", -x*(x-127) w l lw 2.0 lc 0 t "Exact
