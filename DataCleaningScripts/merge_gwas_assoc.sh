#!/bin/bash

# Merge gwas association output files that are separated based on metabolites
# Add a column of metaboliteID
# Association results are from the Shin et al. 2014 study (serum)
# NCBIHackathon 03/12/2018
# Yue Hao

#cd /into/the/data/directory
for file in *.out
do 
    metab=${file:0:6} # extract metabolite id from file name
    #create temp file, add metabolite id at the end of each row
    paste $file <(yes $metab | head -n $(cat $file | wc -l)) > $metab.new 
done

for newfile in *.new
do
    echo -e "$(sed '1d' $newfile)"> $newfile # remove headline in each new file
done

cat *.new > merged_file.txt #merge file
rm *.new #remove temp files
