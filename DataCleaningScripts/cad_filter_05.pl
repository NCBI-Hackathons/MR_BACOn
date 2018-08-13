### filter cad file

open $readfh,'<',"data/cad.add.160614.website.txt" or die "$!";
open $outfh, '>', "data/cad_p05_chrpos.txt" or die "$!";

$header = "SNP\tbeta\tse\teaf\teffect_allele\tother_allele\tpval\tchr\tposn";

print $outfh $header;
$trash = <$readfh>;

while(<$readfh>)
{
$_ =~ s/\./0\./g;

@ls = split(/\s+/, $_);
#print "@ls\n";
$pval = $ls[10];

if($pval < 0.05)
{
#print "$pval\n";
print $outfh "$ls[0]\t$ls[8]\t$ls[9]\t$ls[5]\t$ls[3]\t$ls[4]\t$ls[10]\t$ls[1]\t$ls[2]\n";
}
}