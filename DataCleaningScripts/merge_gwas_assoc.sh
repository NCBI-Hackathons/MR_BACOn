#!/bin/bash

# Merge gwas association output files that are separated based on metabolites
# Add a column of metaboliteID
# Association results are from the Shin et al. 2014 study (serum)
# NCBIHackathon 03/12/2018
# Yue Hao

for file in *.out
do 
    metab=${file:0:6} 
    paste $file <(yes $metab | head -n $(cat $file | wc -l)) > $metab.new 
done

for newfile in *.new
do
    echo -e "$(sed '1d' $newfile)"> $newfile
done

cat *.new > merged_file.txt
rm *.new
