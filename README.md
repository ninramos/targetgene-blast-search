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
sh makelst.sh
```
4. 
