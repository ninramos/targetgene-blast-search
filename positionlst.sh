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
