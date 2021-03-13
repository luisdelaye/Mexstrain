#!/usr/bin/perl

# This script extract the sequences selected by selectM.pl

# use
# perl selectS.pl outfileM nextstrain_ncov_global_metadata.fasta
# out: outfileS
# mv outfileS  nextstrain_ncov_global_metadata.selected.1.fasta

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

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];

my %hash;

open (MIA, "$file1") or die ("No puedo abrir $file1\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ /\w/){
		$hash{$linea} += 1;
	}
}
close (MIA);

my $r = 0;
my $sec;
my $name;

open (MIA, "$file2") or die ("No puedo abrir $file2\n");
open (ROB, ">outfileS") or die ("No puedo abrir outfileS\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ />/ && $r == 1){
		$name =~ s/>//;
		if (exists $hash{$name}){
			print ROB (">$name\n$sec\n");
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
	if (exists $hash{$name}){
		$name =~ s/>//;
		print ROB (">$name\n$sec\n");
	}
	$r = 0;
	$name = $sec = ();
}
close (ROB);
close (MIA);

