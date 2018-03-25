#!/usr/bin/perl

use strict;

#Get pathway information from HMDB dataset.
#03/24/2018
#Yue Hao

my($xmlfile, $readfh, $outfh, $outfile, $line, @array, $IDlist,
   $tempfile, %Metabolite, $metabid, %Subid, %Pathway, $path, $secondid

);

$xmlfile = $ARGV[0];

$tempfile = $xmlfile;
$tempfile =~ s/.xml//g;
$outfile = 'Pathways_'.$tempfile.'.txt';
$tempfile = 'temp_'.$tempfile.'.txt';
$IDlist = 'SecondaryID_'.$tempfile.'.txt';

`./nested_xml_parser.py $xmlfile > $tempfile`;

open $readfh,'<',$tempfile or die "$!";

while (!eof($readfh)) {
	$line = <$readfh>;
    $line =~ s/\r*\n*//g;
    if ($line =~ /^HMDB[0-9]+/) {
        @array = split /\t/, $line;
        $metabid = shift(@array);
        $Metabolite{$metabid} = shift(@array);
        foreach (@array) {
            $Subid{$metabid}{$_} = 0;
        }
    } elsif ($line ne '') {
        $Pathway{$line}{$metabid} = 0;  
    }
    
}
close $readfh;

#system("rm","$tempfile");

open $outfh,'>',$outfile or die "$!";

print $outfh qq{Pathway\tHMDBID\tMetabolite\n};


foreach $path (sort keys %Pathway){
    foreach $metabid (sort keys %{$Pathway{$path}}) {
        print $outfh qq{$path\t$metabid\t$Metabolite{$metabid}\n};
    }
}
close $outfh;
open $outfh,'>',$IDlist or die "$!";
print $outfh qq{HMDBID\tSecondaryID\n};

foreach $metabid (sort keys %Subid){
    foreach $secondid (sort keys %{$Subid{$metabid}}) {
        print $outfh qq{$metabid\t$secondid\n};
    }
}
close$outfh;
