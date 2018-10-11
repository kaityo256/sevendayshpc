set term png
set xla "x"
set yla "T"
set out "fixed.png"
set xra[0:127]

p "data000.dat" w l t "t=0","data010.dat" w l t "t=100","data099.dat" w l t "t=990"
