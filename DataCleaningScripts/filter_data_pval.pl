#!/usr/bin/perl

use strict;

#filter gwas association data with p-value cutoff
# NCBIHackathon 03/12/2018
# Yue Hao

my( $gwas_assoc_file, $tissue, $readfh, $outfile, $outfh, $line, @array,
    $pval_cutoff, $pval, @sub, @new, $first, $second
);

$gwas_assoc_file = $ARGV[0];  #cad.add.160614.website.txt   #merged_serum_gwas.txt  #metab_urine_single_targeted.txt
$pval_cutoff = $ARGV[1];
$tissue = $ARGV[2];


if (scalar(@ARGV) != 3) {
    print qq{Usage: ./filter_data_pval.pl <assoc_file> <Pval_cutoff> <cad | serum | urine>\n};
    exit;
} else {

$outfile = 'filtered_'.$gwas_assoc_file;

open $readfh,'<',$gwas_assoc_file or die "$!";
open $outfh, '>', $outfile or die "$!";

#headline
$line = <$readfh>;

if ($tissue eq 'serum') {
    #column names specified for the LD pruning step:
    #id.exposure = beta (effect)
    #pval.exposure = pvalue
    print $outfh qq{SNP\tchr_name\tchrom_start\tid.exposure\tpval.exposure\tMETID\n};
    while (!eof($readfh)) {
	    $line = <$readfh>;
        $line =~ s/\r?\n*//g;
        @array = split /\t/, $line;
        
        if ($array[6] <= $pval_cutoff) {     # 10^-5
            print $outfh qq{$array[0]\tNA\tNA\t$array[4]\t$array[6]\t$array[7]\n};
        }
    }

} elsif ($tissue eq 'urine') {
    print $outfh qq{SNP\tchr_name\tchrom_start\tid.exposure\tpval.exposure\tMETID\n};
    while (!eof($readfh)) {
	    $line = <$readfh>;
        $line =~ s/\r?\n*//g;
        @array = split /\t/, $line;
        
        if ($array[6] <= $pval_cutoff) {    # 10^-5
            print $outfh qq{$array[2]\t$array[0]\t$array[1]\t$array[8]\t$array[6]\t$array[5]\n};
        }
        
    } 

} elsif ($tissue eq 'cad') {
    print $outfh qq{SNP\tchr_name\tchrom_start\tid.exposure\tpval.exposure\n};
    while (!eof($readfh)) {
	  $line = <$readfh>;
      $line =~ s/\r?\n*//g;
      @array = split /\s+/, $line;  #7.10e-06
      if (scalar(@array) != 13) {
        @new = ();
        foreach(@array){
            if ($_ =~  /\-?\.{1}[0-9]+\.{1}[0-9]+/) {
                $first = $_;
                $first =~ s/^(\-?\.{1}[0-9]+)(\.{1}[0-9]+)$/$1/;
                $second = $_;
                $second =~ s/^(\-?\.{1}[0-9]+)(\.{1}[0-9]+)$/$2/;
                push @new, $first;
                push @new, $second;
             } else {push @new, $_;
             }
         }
         @array = @new;
       }
      #   print scalar(@array)."\n";
           # $array[9] =~ s/([0-9]+\.[0-9]*)(e\-[0-9])/$10$2/g;
    #  $pval = $array[9] +0;
      #    print qq{@array\n};
         if ($array[10] <= $pval_cutoff) { 
            print $outfh qq{$array[0]\t$array[1]\t$array[2]\t$array[8]\t$array[10]\n};
         }
     } 
}

close $outfh;
close $readfh;

}
