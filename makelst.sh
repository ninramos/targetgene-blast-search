#!/bin/sh

cd /scratch/nmnh_corals/ramosn/luciferase_analysis/genome_skim_blast/blastresults/  

for filename in S*blast
        do
        basename=$(basename ${filename} blast)
# removes each unique blast hit from the blastresults tabular output file:
        cut -f1 ${filename} | sort | uniq > ${basename}.lst
	done
