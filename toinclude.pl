#!/usr/local/perl

# This script extracts IDs from a fasta file 

# use
# perl toinclude.pl nextstrain_ncov_global_metadata.fc.fasta Mexico > add_to_include.txt

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
my $country = $ARGV[1];

open (MIA, "$file") or die ("No puedo abrir $file\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ />$country/){
		$linea =~ s/>//;
		print ("$linea\n");
	}
}
close (MIA);
