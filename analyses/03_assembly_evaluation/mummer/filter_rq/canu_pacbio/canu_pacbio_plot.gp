set terminal png tiny size 800,800
set output "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/filter_rq/canu_pacbio/canu_pacbio_plot.png"
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
 "tig00000002" 2775137.0, \
 "tig00000003" 2993706.0, \
 "tig00000004" 3022584.0, \
 "tig00000005" 3037317.0, \
 "tig00000006" 3077329.0, \
 "tig00000007" 3092345.0, \
 "tig00000009" 3108466.0, \
 "tig00000010" 3133297.0, \
 "tig00000011" 3148751.0, \
 "" 3155801 \
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
set yrange [1:3155801]
set style line 1  lt 1 lw 3 pt 6 ps 1
set style line 2  lt 3 lw 3 pt 6 ps 1
set style line 3  lt 2 lw 3 pt 6 ps 1
plot \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/filter_rq/canu_pacbio/canu_pacbio_plot.fplot" title "FWD" w lp ls 1, \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/filter_rq/canu_pacbio/canu_pacbio_plot.rplot" title "REV" w lp ls 2
