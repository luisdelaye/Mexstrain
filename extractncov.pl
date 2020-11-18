#!/usr/bin/perl

# This script extracts fasta sequences represented in the metadata file downloaded from a Nextstrain analysis

# use
# perl extraencov.pl nextstrain_ncov_global_metadata.tsv sequences.fasta

# out: outfile.fasta

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
my $fast = $ARGV[1];

my %hash;

my $l = 0;
my $n = 0;

open (MIA, "$file") or die ("Can't open file $file\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
	if ($l > 1){
		my @a = split (/\t/, $linea);
		$hash{$a[0]} = 1;
		print ("($a[0])\n");
		$n++;
		#my $pausa = <STDIN>;
	}
}
close (MIA);
print ("\nn: $n\n");

my $r = 0;
my $sec;
my $name;

open (MIA, "$fast") or die ("Can't open file $fast\n");
open (ROB, ">outfile.fasta") or die ("Can't open file outfile.fasta\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ />/ && $r == 1){
		my $nombre = $name;
		$nombre =~ s/>//;
		if (exists $hash{$nombre}){
			print ROB ("$name\n");
			print ROB ("$sec\n");
		}
		$r = 0;
		$name = $sec = ();
	}
	if ($linea !~ />/ && $r == 1){
		$sec = $sec.$linea;
	}
	if ($linea =~ />/ && $r == 0){
		$name = $linea;
		$r = 1;
	}
}
if ($r == 1){
	my $nombre = $name;
	$nombre =~ s/>//;
	if (exists $hash{$nombre}){
		print ROB ("$name\n");
		print ROB ("$sec\n");
	}
	$r = 0;
	$name = $sec = ();
}
close (ROB);
close (MIA);


