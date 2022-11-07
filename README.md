## Blast with target gene of interest


1. To run blast, first create a built blast database with target enrichment data for luciferase (exon 129)

```
mkdir -p blastdb 
mv 129exon.fasta blastdb/
cd blastdb/ 

makeblastdb -in 129exon.fasta -dbtype nucl -out luciferasedb

 ```
 
 2. Move to directory with query sequences (S***.contigs.fasta) you wish to blast with luciferasedb and run blastn
 
 ```
blastn -db <luciferasedb> -query <query fastas> -outfmt 6 -evalue 1e-5 -out <output filename(S*blast)>
```

 Move all blast results to one directory 
 
 ```
 mv S*blast blastresults/
 
 ```
 
 ## Extract blast hit sequences from blastn outfmt 6 output file 
 
 
1. In a directory with all blastresults, create a list of all unique hits with **makelst.sh**
 
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

```
cat *.lst >> alluniquehits.lst 

```

2. Pull the blast hit sequences using the unique hits lists from contig files with blast_hits.sh
  
```
nano blast_hits.sh
```

```
#blast_hits.sh
#!/bin/sh
for filename in S*blast
        do
        basename=$(basename ${filename} blast)
        seqtk subseq ${basename}.contigs.fasta ${basename}.lst > ${basename}.fasta 
        done
```

```
sh blast_hits.sh 
```

concatenate all pulled sequences into one file

```
cat *.fasta >> all_luciferase_seq.fasta
```
	
	
> **all_luciferase_seq.fasta** Contains the full fasta sequence for each unique hit identified. 



3. Add the contig ID to each head of the fasta sequences pulled, run **rename.sh**

```
nano rename.sh
```

```
#rename.sh
#!/bin/sh

for filename in S*.fasta
        do 
        basename=$(basename ${filename} .fasta)
        sed "s+>+>${basename}_+g" "$filename" >> ${basename}named.fasta
        done
```

```
cat *named.fasta >> all_luciferase_seq_named.fasta
```

## Trim sequences to specific blast hit region
        
1. Get NodeID, Start, and Stop positions by running positions.lst and then use with Bedtools. 

```
nano positionslst.sh
```
```
#!/bin/sh

for filename in S*blast
        do
        basename=$(basename ${filename} blast)
# removes each unique blast hit, length, start and stop of alignment from the blastresults tabular output file:
        cut -f 1,4,7,8 ${filename} | sort -r -k 2 | uniq > ${basename}length.lst #sorts in descending order by alignment hit length
	done

#prints the first unique value based on first column,  removes repeate nodes w/ shorter alignment lengths
for filename in S*length.lst
	do
	basename=$(basename ${filename} length.lst)
	awk '!seen[$1]++' ${filename} > ${basename}position1.lst
	done

#gets the NodeID, start, and stop position. Removes alignment length
for filename in S*position1.lst
	do
	basename=$(basename ${filename} position1.lst)
	cut -f 1,3,4 ${filename} | sort | uniq > ${basename}positionfinal.lst
	done

#renames NodeID to include Contig ID (i.e. S001)
for filename in S*positionfinal.lst
        do
	basename=$(basename ${filename} positionfinal.lst)
        sed "s+NODE+${basename}_NODE+g" "$filename" > ${basename}name-position.lst
        done

#clean up intermediate files 

rm S*length.lst
 
rm S*positionfinal.lst

rm S*position1.lst

#create master list of NodeID & position
cat S*name-position.lst >> luciferase_namepositions.lst
        
```

```
sh positionlst.sh
```

> **luciferase_namepositions.lst** is a tab deliminated file with the start stop positions according to blast, column 1 headers in this file need to be exact to those in the fasta sequences file

2. Use bedtools to extract region of genome contig/node sequence that blasted to luciferases

```
bedtools getfasta -fi all_luciferase_seq_named.fasta -bed luciferase_namepositions.lst -fo genomeskim_luciferases_extracted.fa
```

 
