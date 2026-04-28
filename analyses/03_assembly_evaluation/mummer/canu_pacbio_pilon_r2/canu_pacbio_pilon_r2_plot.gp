set terminal png tiny size 1400,1400
set output "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/canu_pacbio_pilon_r2/canu_pacbio_pilon_r2_plot.png"
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
 "tig00000001_pilon_pilon" 1.0, \
 "tig00000002_pilon_pilon" 2775212.0, \
 "tig00000003_pilon_pilon" 2993788.0, \
 "tig00000004_pilon_pilon" 3022674.0, \
 "tig00000005_pilon_pilon" 3037410.0, \
 "tig00000006_pilon_pilon" 3077422.0, \
 "tig00000007_pilon_pilon" 3092442.0, \
 "tig00000009_pilon_pilon" 3108568.0, \
 "tig00000010_pilon_pilon" 3133419.0, \
 "tig00000011_pilon_pilon" 3148873.0, \
 "" 3155923 \
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
set yrange [1:3155923]
set style line 1  lt 1 lw 3 pt 6 ps 1
set style line 2  lt 3 lw 3 pt 6 ps 1
set style line 3  lt 2 lw 3 pt 6 ps 1
plot \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/canu_pacbio_pilon_r2/canu_pacbio_pilon_r2_plot.fplot" title "FWD" w lp ls 1, \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/canu_pacbio_pilon_r2/canu_pacbio_pilon_r2_plot.rplot" title "REV" w lp ls 2
