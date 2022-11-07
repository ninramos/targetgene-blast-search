## Blasting with target gene of interest
The following describes the pipeline for using blast to search for and extract luciferase genes for bioinformatic analysis. 


1. To run blast, first create a blast database: 

Move all contig files into their own directory to build local blast database. 

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
        done
 ```
 Create blast database with **make_blast_db.sh** from the contigs. 
 
 ```
 sh make_blast_db.sh
 ```
 
 2. Move to directory with query sequences you wish to blast with newly made blastdb and run blastn
 
 ```
blastn -db <blastdb> -query <query fastas> -outfmt 6 -evalue 1e-5 -out <output filename>
```

 Move all blast results to one directory 
 
 ```
 mv *blast blastresults/
 
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
        sed "s+>+>${basename}_+g" "$filename" >> ${basename}renamed.fasta
        done
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
 
