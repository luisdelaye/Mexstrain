#!/usr/bin/perl

# This script sample rows from a metadata.tsv file 
# sampling is not random, it will select the first rows with desired characteristics

# use
# perl selectM.pl nextstrain_ncov_global_metadata.tsv N1 N2 > nextstrain_ncov_global_metadata.selected.N2.tsv
# out: outfileM
# where N1 refers to the nextstrain_ncov_global_metadata.tsv column, chose N1 == 6 for country
# and N2 refers to the maximum number of rows from each category specified by N1.
# For example, if N1 == 6 and N2 == 10, you will select the first 10 rows (genomes) from each country in the file.

# See https://github.com/luisdelaye/Mexstrain/ for more details

# Author
# Luis Jose Delaye Arredondo
# Laboratorio de Genomica Evolutiva
# Departamento de Ingenieria Genetica
# CINVESTAV - Irapuato
# Mexico
# luis.delaye@cinvestav.mx
# Copy-Left  = : - )

# beta.1.0 version

use strict;

my $file = $ARGV[0];
my $col  = $ARGV[1];
my $max  = $ARGV[2];

my %hash;
my $hashA = {};
my $l = 0;
my $header;

open (MIA, "$file") or die ("No puedo abrir $file\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
	if ($l > 1){
		my @a = split (/\t/, $linea);
		if ($hash{$a[$col]} < $max){
			push (@{$hashA->{$a[$col]}}, $linea);
			$hash{$a[$col]} += 1;
		} elsif ($a[0] =~ /Wuhan\/Hu-1\/2019/ || $a[0] =~ /Wuhan-Hu-1\/2019/ || $a[0] =~ /Wuhan\/WH01\/2019/){
			push (@{$hashA->{$a[$col]}}, $linea);
			$hash{$a[$col]} += 1;
		}
	} else {
		$header = $linea;
		print ("$header\n");
	}
}
close (MIA);

my @keys = sort keys (%hash);

open (ROB, ">outfileM") or die ("No puedo abrir outfileM\n");
for (my $i = 0; $i <= $#keys; $i++){
	my $j = $i+1;
	my @a = @{$hashA->{$keys[$i]}};
	my @b = split (/\s/, $a[0]);
	#print ("($j)\t$keys[$i]\t$hash{$keys[$i]}\t($b[0])\n");
	#print ("@{$hashA->{$keys[$i]}}\n");
	for (my $j = 0; $j <= $#{$hashA->{$keys[$i]}}; $j++){
		print ("${$hashA->{$keys[$i]}}[$j]\n");
		my @c = split (/\t/, ${$hashA->{$keys[$i]}}[$j]);
		print ROB ("$c[0]\n");
	}
	#print ROB ("$b[0]\n");
}
close (ROB);
