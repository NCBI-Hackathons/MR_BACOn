head -500 < data/mr_data/cad.txt \
| awk '{if(NR == 1) {print $0"\tmetID"} \
if(NR > 1) {print $0"\tM00053"}}' \
> data/mr_data/cad_subset.txt

