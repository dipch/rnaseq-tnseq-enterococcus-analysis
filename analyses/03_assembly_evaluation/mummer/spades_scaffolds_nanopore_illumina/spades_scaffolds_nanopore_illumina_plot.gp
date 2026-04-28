set terminal png tiny size 1400,1400
set output "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/spades_scaffolds_nanopore_illumina/spades_scaffolds_nanopore_illumina_plot.png"
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
 "NODE_1_length_1652082_cov_46.167482" 1.0, \
 "NODE_2_length_840748_cov_42.698360" 1652082.0, \
 "NODE_3_length_245057_cov_46.274867" 2492829.0, \
 "NODE_4_length_212759_cov_102.864112" 2737885.0, \
 "NODE_5_length_73637_cov_93.923133" 2950643.0, \
 "NODE_6_length_62897_cov_74.026034" 3024279.0, \
 "NODE_7_length_35882_cov_232.232618" 3087175.0, \
 "NODE_8_length_9417_cov_147.340953" 3123056.0, \
 "NODE_9_length_5232_cov_70.113772" 3132472.0, \
 "NODE_10_length_3276_cov_241.102763" 3137703.0, \
 "NODE_11_length_519_cov_37.771552" 3140978.0, \
 "NODE_12_length_446_cov_35.685422" 3141496.0, \
 "NODE_13_length_387_cov_37.397590" 3141941.0, \
 "NODE_14_length_375_cov_31.812500" 3142327.0, \
 "NODE_15_length_356_cov_0.481728" 3142701.0, \
 "NODE_16_length_352_cov_38.013468" 3143056.0, \
 "NODE_17_length_341_cov_35.150350" 3143407.0, \
 "NODE_18_length_341_cov_30.041958" 3143747.0, \
 "NODE_19_length_332_cov_0.274368" 3144087.0, \
 "NODE_20_length_311_cov_39.867188" 3144418.0, \
 "NODE_21_length_266_cov_38.578199" 3144728.0, \
 "NODE_22_length_249_cov_35.623711" 3144993.0, \
 "NODE_23_length_243_cov_32.414894" 3145241.0, \
 "NODE_24_length_228_cov_34.907514" 3145483.0, \
 "NODE_25_length_224_cov_32.189349" 3145710.0, \
 "NODE_26_length_163_cov_30.490741" 3145933.0, \
 "NODE_27_length_128_cov_136.301370" 3146095.0, \
 "NODE_28_length_126_cov_32.957746" 3146222.0, \
 "NODE_29_length_124_cov_131.797101" 3146347.0, \
 "NODE_30_length_117_cov_26.435484" 3146470.0, \
 "NODE_31_length_113_cov_28.155172" 3146586.0, \
 "NODE_32_length_112_cov_52.877193" 3146698.0, \
 "NODE_33_length_112_cov_40.964912" 3146809.0, \
 "NODE_34_length_95_cov_28.800000" 3146920.0, \
 "NODE_35_length_80_cov_144.920000" 3147014.0, \
 "NODE_36_length_77_cov_30.727273" 3147093.0, \
 "NODE_37_length_62_cov_3.000000" 3147169.0, \
 "NODE_38_length_62_cov_1.428571" 3147230.0, \
 "NODE_39_length_61_cov_69.833333" 3147291.0, \
 "NODE_40_length_56_cov_68.000000" 3147351.0, \
 "" 3147445 \
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
set yrange [1:3147445]
set style line 1  lt 1 lw 3 pt 6 ps 1
set style line 2  lt 3 lw 3 pt 6 ps 1
set style line 3  lt 2 lw 3 pt 6 ps 1
plot \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/spades_scaffolds_nanopore_illumina/spades_scaffolds_nanopore_illumina_plot.fplot" title "FWD" w lp ls 1, \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/spades_scaffolds_nanopore_illumina/spades_scaffolds_nanopore_illumina_plot.rplot" title "REV" w lp ls 2
