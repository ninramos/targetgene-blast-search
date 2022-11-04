## Blasting with target gene of interest & extracting sequences from blast output 

1. Create blast database: 

Move all contig files into their own directory to create blast database. 

```
mkdir -p blastdb 
mv *.contigs.fasta blastdb/
nano make_blast_db.sh
```

```
##make_blast_db.sh

#!/bin/sh
for filename in *.contigs.fasta
        do
        name=$(basename $filename .contigs.fasta) #creates a variable "name"
        makeblastdb -dbtype nucl -in $filename -out $name #makes local BLAST database
        mv $name.n* blastdb #moves new file to directory called “blastdb”
        done
 ```
 Create blast database with **make_blast_db.sh** from the contigs. 
 
 ```
 sh make_blast_db.sh
 ```
 
 2. Move to directory with sequences you wish to blast with newly made blastdb and run blastn
 
 ```
blastn -db path/to/blastdb -query *.contigs.fasta -outfmt 6 -evalue 1e-5 -out path/to/output/blastresults
```
 
 3. In a directory with all blastresutls, create list with all unique hits with **makelst.sh**
 
 ```
 nano makelst.sh
```

```
#makelst.sh

#!/bin/sh
for filename in S*blast
        do
        basename=$(basename ${filename} blast)
# removes each unique blast hit from the blastresults tabular output file:
        cut -f1 ${filename} | sort | uniq > ${basename}.lst
        done
        
```

```
sh makelst.sh
```
4. pull blast hit sequences from contig files with blast_hits.sh
  
```
nano blast_hits.sh
```

```
#blast_hits.sh
#!/bin/sh
for filename in S*blast
        do
        basename=$(basename ${filename} blast)
        seqtk subseq /scratch/nmnh_corals/quattrinia/analysis/genomeskims/Jul2022/spades-assemblies/${basename}.contigs.fasta /scratch/nmnh_corals/ramosn/luciferase_analysis/genome_skim_blast/blastresults/${basename}.lst > ${basename}.fasta 
        done
```

concatenate all pulled sequences into one file

```
cat *.fasta >> all_luciferase_seq.fasta
```

5. to add the contig ID to each head of the fasta sequences pulled, run **rename.sh**

```
nano rename.sh
```

```
#rename.sh
#!/bin/sh

for filename in S*.fasta
        do 
        basename=$(basename ${filename} .fasta)
        sed "s+>+>${basename}_+g" "$filename" >> ${basename}renamed.fasta
        done
```
        
6. To get NodeID, Start, and Stop positions run positions.lst. This can then be used with bedtools 

```
nano positionslst.sh
```
#!/bin/sh
for filename in S*blast
        do
	basename=$(basename ${filename} blast)
# removes each unique blast hit, length, start and stop of alignment from the blastresults tabular ou$
        cut -f 1,4,7,8 ${filename} | sort -r -k 2 | uniq > ${basename}length.lst #sorts in descending$
        done

#prints the first unique value based on first column, so should remove repeate nodes w/ shorter align$
for filename in S*length.lst
        do
	basename=$(basename ${filename} length.lst)
        awk '!seen[$1]++' ${filename} > ${basename}position.lst
        done
        
#gets the NodeID, start, and stop position. Removes alignment length
for filename in S*position.lst
        do
	cut -f 1,3,4 ${filename} | sort | uniq > ${basename}positionfinal.lst
        done
        
```
 
