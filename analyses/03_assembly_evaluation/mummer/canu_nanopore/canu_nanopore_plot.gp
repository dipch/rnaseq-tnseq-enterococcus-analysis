set terminal png tiny size 1400,1400
set output "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/canu_nanopore/canu_nanopore_plot.png"
set xtics rotate ( \
 "NZ_CP014529.1" 1.0, \
 "NZ_CP014530.1" 2765010.0, \
 "NZ_CP014531.1" 2988697.0, \
 "NZ_CP014532.1" 3021119.0, \
 "NZ_CP014533.1" 3030428.0, \
 "NZ_CP014534.1" 3047681.0, \
 "NZ_CP014535.1" 3102847.0, \
 "" 3168410 \
)
set ytics ( \
 "tig00000001" 1.0, \
 "tig00000002" 23096.0, \
 "tig00000003" 31574.0, \
 "tig00000004" 41078.0, \
 "tig00000005" 51188.0, \
 "tig00000006" 66278.0, \
 "tig00000007" 80886.0, \
 "tig00000008" 93807.0, \
 "tig00000009" 105648.0, \
 "tig00000010" 115392.0, \
 "tig00000011" 118888.0, \
 "tig00000012" 131213.0, \
 "tig00000013" 134637.0, \
 "tig00000014" 141842.0, \
 "tig00000015" 150075.0, \
 "tig00000016" 162755.0, \
 "tig00000017" 177148.0, \
 "tig00000018" 184454.0, \
 "tig00000019" 190364.0, \
 "tig00000020" 204001.0, \
 "tig00000021" 209643.0, \
 "tig00000022" 214665.0, \
 "tig00000023" 225087.0, \
 "tig00000024" 226319.0, \
 "tig00000025" 230097.0, \
 "tig00000026" 238500.0, \
 "tig00000027" 245168.0, \
 "tig00000028" 254006.0, \
 "tig00000029" 262167.0, \
 "tig00000030" 266437.0, \
 "tig00000031" 278756.0, \
 "tig00000032" 283145.0, \
 "tig00000033" 287802.0, \
 "tig00000034" 293650.0, \
 "tig00000035" 302195.0, \
 "tig00000036" 306138.0, \
 "tig00000037" 310166.0, \
 "tig00000038" 324458.0, \
 "tig00000039" 330653.0, \
 "tig00000040" 340617.0, \
 "tig00000041" 346348.0, \
 "tig00000042" 356421.0, \
 "tig00000043" 359841.0, \
 "tig00000044" 364740.0, \
 "" 367099 \
)
set size 1,1
set grid
unset key
set border 0
set tics scale 0
set xlabel "REF"
set ylabel "QRY"
set format "%.0f"
set mouse format "%.0f"
set mouse mouseformat "[%.0f, %.0f]"
set xrange [1:3168410]
set yrange [1:367099]
set style line 1  lt 1 lw 3 pt 6 ps 1
set style line 2  lt 3 lw 3 pt 6 ps 1
set style line 3  lt 2 lw 3 pt 6 ps 1
plot \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/canu_nanopore/canu_nanopore_plot.fplot" title "FWD" w lp ls 1, \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/canu_nanopore/canu_nanopore_plot.rplot" title "REV" w lp ls 2
