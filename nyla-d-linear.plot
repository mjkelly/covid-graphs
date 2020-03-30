set xdata time
set ylabel "Deaths per 1000 people"
set key left top
set timefmt "%Y-%m-%d"
set terminal pngcairo size 700,524 enhanced font "Verdana,10"
set output "nyla-d-linear.png"
plot for [i=2:3] "nyla-d.tsv" using 1:i title columnhead with lines
