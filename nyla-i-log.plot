set xdata time
set ylabel "Infections per 1000 people"
set key left top
set timefmt "%Y-%m-%d"
set terminal pngcairo size 700,524 enhanced font "Verdana,10"
set logscale y
set output "nyla-i-log.png"
plot for [i=2:3] "nyla-i.tsv" using 1:i title columnhead with lines
