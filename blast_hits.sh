#!/bin/sh

for filename in S*blast
	do
	basename=$(basename ${filename} blast)
	seqtk subseq /scratch/nmnh_corals/quattrinia/analysis/genomeskims/Jul2022/spades-assemblies/${basename}.contigs.fasta /scratch/nmnh_corals/ramosn/luciferase_analysis/genome_skim_blast/blastresults/${basename}.lst > ${basename}.fasta 
	done
