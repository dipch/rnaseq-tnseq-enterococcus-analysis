set terminal png tiny size 1400,1400
set output "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/flye_pacbio_pilon/flye_pacbio_pilon_plot.png"
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
 "contig_1_pilon" 1.0, \
 "contig_10_pilon" 1362979.0, \
 "contig_11_pilon" 1395402.0, \
 "contig_12_pilon" 1594787.0, \
 "contig_2_pilon" 1613982.0, \
 "contig_3_pilon" 3029023.0, \
 "contig_4_pilon" 3067656.0, \
 "contig_5_pilon" 3083655.0, \
 "contig_7_pilon" 3087296.0, \
 "contig_8_pilon" 3114471.0, \
 "contig_9_pilon" 3125234.0, \
 "" 3139688 \
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
set yrange [1:3139688]
set style line 1  lt 1 lw 3 pt 6 ps 1
set style line 2  lt 3 lw 3 pt 6 ps 1
set style line 3  lt 2 lw 3 pt 6 ps 1
plot \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/flye_pacbio_pilon/flye_pacbio_pilon_plot.fplot" title "FWD" w lp ls 1, \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/flye_pacbio_pilon/flye_pacbio_pilon_plot.rplot" title "REV" w lp ls 2
