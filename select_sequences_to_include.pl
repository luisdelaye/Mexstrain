#!/usr/local/perl

# This script extracts IDs from a fasta file.

# use
# perl select_sequences_to_include.pl sequences.sampled.fasta Mexico > add_to_the_include_file.txt

# See https://github.com/luisdelaye/Mexstrain/ for more details.

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
#-------------------------------------------------------------------------------
# Declare global variables
my $file = $ARGV[0];
my $country = $ARGV[1];

$country =~ s/_/\s/g;

#-------------------------------------------------------------------------------
# Extract the names of the sequences

open (MIA, "$file") or die ("Can't open $file\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ /\/$country\//){
		$linea =~ s/>//;
		print ("$linea\n");
	}
}
close (MIA);
#-------------------------------------------------------------------------------
