set terminal png tiny size 1400,1400
set output "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/flye_nanopore/flye_nanopore_plot.png"
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
 "contig_1" 1.0, \
 "contig_10" 47447.0, \
 "contig_11" 99426.0, \
 "contig_12" 151191.0, \
 "contig_13" 178785.0, \
 "contig_14" 202212.0, \
 "contig_15" 211477.0, \
 "contig_16" 217006.0, \
 "contig_17" 225614.0, \
 "contig_18" 234348.0, \
 "contig_19" 273055.0, \
 "contig_2" 309836.0, \
 "contig_20" 703177.0, \
 "contig_21" 726824.0, \
 "contig_22" 791986.0, \
 "contig_23" 800872.0, \
 "contig_24" 812902.0, \
 "contig_25" 875335.0, \
 "contig_26" 887181.0, \
 "contig_27" 896500.0, \
 "contig_28" 977088.0, \
 "contig_29" 1005663.0, \
 "contig_3" 1314926.0, \
 "contig_30" 1342361.0, \
 "contig_31" 1345506.0, \
 "contig_32" 1368157.0, \
 "contig_34" 1480417.0, \
 "contig_35" 1582118.0, \
 "contig_36" 1592720.0, \
 "contig_37" 1631098.0, \
 "contig_38" 1669467.0, \
 "contig_39" 1682410.0, \
 "contig_4" 1698509.0, \
 "contig_40" 1733230.0, \
 "contig_41" 1847428.0, \
 "contig_42" 1863282.0, \
 "contig_43" 1882912.0, \
 "contig_44" 1901972.0, \
 "contig_45" 1915020.0, \
 "contig_46" 2021707.0, \
 "contig_47" 2029606.0, \
 "contig_48" 2043397.0, \
 "contig_49" 2171102.0, \
 "contig_5" 2201724.0, \
 "contig_50" 2300117.0, \
 "contig_51" 2318441.0, \
 "contig_52" 2338183.0, \
 "contig_53" 2366889.0, \
 "contig_54" 2406060.0, \
 "contig_55" 2489707.0, \
 "contig_56" 2520102.0, \
 "contig_57" 2546071.0, \
 "contig_58" 2600854.0, \
 "contig_59" 2686227.0, \
 "contig_6" 2697839.0, \
 "contig_60" 2728066.0, \
 "contig_61" 2843152.0, \
 "contig_62" 2993991.0, \
 "contig_63" 3011352.0, \
 "contig_64" 3021020.0, \
 "contig_65" 3078427.0, \
 "contig_66" 3124604.0, \
 "contig_67" 3216058.0, \
 "contig_68" 3221152.0, \
 "contig_69" 3236331.0, \
 "contig_7" 3259338.0, \
 "contig_70" 3296374.0, \
 "contig_71" 3320069.0, \
 "contig_72" 3339201.0, \
 "contig_73" 3386614.0, \
 "contig_74" 3546730.0, \
 "contig_75" 3609156.0, \
 "contig_76" 3616657.0, \
 "contig_77" 3645722.0, \
 "contig_78" 3648988.0, \
 "contig_79" 3673523.0, \
 "contig_8" 3700493.0, \
 "contig_80" 3714877.0, \
 "contig_81" 3732803.0, \
 "contig_82" 3772248.0, \
 "contig_83" 3779307.0, \
 "contig_84" 3806869.0, \
 "contig_85" 3818548.0, \
 "contig_9" 3868621.0, \
 "" 3884554 \
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
set yrange [1:3884554]
set style line 1  lt 1 lw 3 pt 6 ps 1
set style line 2  lt 3 lw 3 pt 6 ps 1
set style line 3  lt 2 lw 3 pt 6 ps 1
plot \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/flye_nanopore/flye_nanopore_plot.fplot" title "FWD" w lp ls 1, \
 "/home/dich3309/rnaseq-tnseq-enterococcus-analysis/analyses/03_assembly_evaluation/mummer/flye_nanopore/flye_nanopore_plot.rplot" title "REV" w lp ls 2
