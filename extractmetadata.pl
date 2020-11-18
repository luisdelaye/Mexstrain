#!/usr/bin/perl

# This script extracts metadata from IDs represented in the metadata file downloaded from a Nextstrain analysis

# use
# perl extractmetadata.pl nextstrain_ncov_global_metadata.fasta metadata.tsv

# out: outfile

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

my $fileF = $ARGV[0];
my $fileM = $ARGV[1];

my %ids;
my $n = 0;

open (MIA, "$fileF") or die ("Can't open file $fileF\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ />/){
		if ($linea =~ />(.+)/){
			print ("($1)\n");
			$ids{$1} = 1;
			$n++;
		} else {
			die ("Pattern matching recognition failed: ($linea)\n");
		}
	}
}
close (MIA);

my $l = 0;
my $m = 0;
open (MIA, "$fileM") or die ("Can't open file $fileM\n");
open (ROB, ">outfile") or die ("Can't open file outfile\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
	if ($l == 1){
		print ROB ("$linea\n");
	}
	my @a = split (/\t/, $linea);
	if (exists $ids{$a[0]}){
		print ROB ("$linea\n");
		$m++;
	}
}
close (ROB);
close (MIA);

print ("found $m of $n\n");