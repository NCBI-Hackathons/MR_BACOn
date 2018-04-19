#!/usr/bin/perl

use strict;

# Find SNPs that appear both in targeted metabolite GWAS data (serum or urine), and in the trait (CAD) GWAS data
# Apply raw P-value cutoff: 10^-5 (serum data was already filtered)
# NCBIHackathon 03/12/2018
# Yue Hao

# column names for LD pruning step
# for clumping we need colnames -> c("SNP", "chr_name", "chrom_start", "id.exposure", "pval.exposure")
# SNPid chr pos beta pval metid

my( $trait_gwas_file, $metab_gwas_file, $tissue, $readfh, $outfile1, $outfile2, $outfh1, $outfh2, $line, @array,
    %Beta, %Pval, %Chrom, %Pos, %Trait, $metid, $num, $i
);

$trait_gwas_file = $ARGV[0];
#cad.add.160614.website.txt
#markername	chr	bp_hg19	effect_allele	noneffect_allele	effect_allele_freq	median_info	model	beta	se_dgc	p_dgc	het_pvalue	n_studies

$metab_gwas_file = $ARGV[1];
#merged_serum_gwas.txt
#MarkerName	Allele1	Allele2	Freq1	Effect	StdErr	P-value	MetID
#metab_urine_single_targeted.txt
#CHR	POS	SNP	EA	MET	METID	P	BETAPRIME	BETA	SE	NMISS
$tissue = $ARGV[2];
#serum or urine
 
if (scalar(@ARGV) != 3) {
    print qq{Usage: ./get_intersect_snps <trait_assoc_file> <metab_assoc_file> <serum | urine>\n};
    exit;
} else {


$outfile2 = 'intersect_'.$metab_gwas_file;

open $readfh,'<',$metab_gwas_file or die "$!";

#headline
$line = <$readfh>;

if ($tissue eq 'serum') {
    $outfile1 = 'intersect_s_'.$trait_gwas_file;
    while (!eof($readfh)) {
	    $line = <$readfh>;
        $line =~ s/\r?\n*//g;
        @array = split /\t/, $line;
        $Beta{$array[0]}{$array[7]} = $array[4];
        $Pval{$array[0]}{$array[7]} = $array[6]; # >10^-5
  #      $Chrom{$array[0]}{$array[7]} = $array[8];
  #      $Pos{$array[0]}{$array[7]} = $array[9];
    }

} elsif ($tissue eq 'urine') {
    $outfile1 = 'intersect_u_'.$trait_gwas_file;
    while (!eof($readfh)) {
	    $line = <$readfh>;
        $line =~ s/\r?\n*//g;
        @array = split /\t/, $line;
        if ($array[6] <= 0.00001) {
            $Beta{$array[2]}{$array[5]} = $array[8];
            $Pval{$array[2]}{$array[5]} = $array[6]; # >10^-5
            $Chrom{$array[2]}{$array[5]} = $array[0];
            $Pos{$array[2]}{$array[5]} = $array[1];
        }
    }     
    
    
}   
close $readfh;

$num = keys %Pval;
print qq{Total number of snps for $tissue: $num.\n};     
         


open $readfh,'<',$trait_gwas_file or die "$!";
open $outfh1, '>', $outfile1 or die "$!";
open $outfh2, '>', $outfile2 or die "$!";

#column names specified for the LD pruning step:
print $outfh1 qq{SNP\tCHR\tPOS\tBETA\tP\n};
print $outfh2 qq{SNP\tCHR\tPOS\tBETA\tP\tMETID\n};

$i = 0;
while (!eof($readfh)) {
	  $line = <$readfh>;
      $line =~ s/\r?\n*//g;
      @array = split /\t/, $line;
      if (exists $Pval{$array[0]}) {
        if ($array[9] <= 0.05) { 
            print $outfh1 qq{$array[0]\t$array[1]\t$array[2]\t$array[8]\t$array[9]\n};
            $i++;
            foreach $metid (keys ${Pval{$array[0]}}){
                if (exists $Chrom{$array[0]}) {
                    print $outfh2 qq{$array[0]\t$Chrom{$array[0]}{$metid}\t$Pos{$array[0]}{$metid}\t$Beta{$array[0]}{$metid}\t$Pval{$array[0]}{$metid}\t$metid\n};
                } else {
                    print $outfh2 qq{$array[0]\tNA\tNA\t$Beta{$array[0]}{$metid}\t$Pval{$array[0]}{$metid}\t$metid\n};
                }
            }
        }
      }
}
close $readfh;
close $outfh1;
close $outfh2;

print qq{Intersection: $i.\n};

}
      
      
