#!/usr/bin/perl

# This script creates a file named outfile.tsv which is a copy of metadata.tsv
# with some of the names of the geographic localities changed to match those of
# color_ordering.tsv for Nextstrain analysis.

# use
# perl substitute_names.pl metadata.tsv substitute_proposal.tsv
# out:
# outfile.tsv

# 'substitute.tsv' is a text file containing the names of the geographic places
# to be substituted. The file has three columns separated by tabs. The first
# column shows the metadata.tsv name that is lacking in color_ordering.tsv, the
# second column shows the geographical context of the name and the third column
# shows again the geographical context of the name. Each column is separated by
# a tab.
# Remember that the names of the geographic localities must follow the next
# structure:

# region / country / division / location

# Example of a substitute_proposal.tsv file is shown below:

# 'Asientos'  'North America / Mexico / Aguascalientes / Asientos'  'North America / Mexico / Aguascalientes / Asientos'
# 'Calvillo'  'North America / Mexico / Aguascalientes / Calvillo'  'North America / Mexico / Aguascalientes / Calvillo'
# 'Jesus Maria' 'North America / Mexico / Aguascalientes / Jesus Maria' 'North America / Mexico / Aguascalientes / Jesus Maria'
# 'Pabello de A'  'North America / Mexico / Aguascalientes / Pabello de A'  'North America / Mexico / Aguascalientes / Pabello de A'
# 'Aguascallientes' 'North America / Mexico / Aguascallientes / Aguascalientes' 'North America / Mexico / Aguascallientes / Aguascalientes'
# 'Tecate'  'North America / Mexico / Baja California / Tecate' 'North America / Mexico / Baja California / Tecate'
# 'Los Cabos' 'North America / Mexico / Baja California Sur / Los Cabos'  'North America / Mexico / Baja California Sur / Los Cabos'
# 'Tecate'  'North America / Mexico / Baja California Sur / Tecate' 'North America / Mexico / Baja California Sur / Tecate'
# 'CDMX'  'North America / Mexico / CDMX' 'North America / Mexico / CDMX'
# 'CMX' 'North America / Mexico / CMX'  'North America / Mexico / CMX'
# 'Calkini' 'North America / Mexico / Campeche / Calkini' 'North America / Mexico / Campeche / Calkini'

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
# Global variables

my $fileMe   = $ARGV[0]; # metadata.tsv file
my $subsfile = $ARGV[1]; # the name of the file with the names to substitute

my %hashCo;              # category of geographic localities
my %country;             # Country of reference
my %hashSub;             # names to be substituted
my %substitutions;
my $l = 0;
my $n = 0;

#-------------------------------------------------------------------------------
# Check if an outfile.tsv file already exists

if (-e 'outfile.tsv'){
	print ("\n------------------------------------------------------------------------\n");
	print ("A file named outfile.tsv already exists.\n");
	print ("If you continue with the analysis, its content will be replaced.\n");
	print ("Do you want to continue? (y/n)\n");
	my $answer = <STDIN>;
	if ($answer =~ /n/i){
		die;
	} else {
		system ("rm outfile.tsv\n")
	}
}

#-------------------------------------------------------------------------------
# Gather information from the substitution_proposal.tsv file
if (-e $subsfile){
	print ("------------------------------------------------------------------------\n");
	print ("A substitute_proposal.tsv file was provided: $subsfile\n");
	print ("------------------------------------------------------------------------\n");
	open (MIA, "$subsfile") or die ("Can't open $subsfile\n");
	while (my $linea = <MIA>){
		chomp ($linea);
	    my @a = split (/\t/, $linea);
			if ($a[1] =~ /^'(.+)'$/){
				my $uno = $1;
				if ($a[2] =~ /^'(.+)'$/){
					my $dos = $1;
					if ($uno ne $dos){
						$hashSub{$uno} = $dos;
					}
				} else {
					die ("Error in $subsfile, please check\nquotation marks are lacking in: $a[2]\n");
				}
			} else {
				die ("Error in $subsfile, please check\nquotation marks are lacking in: $a[1]\n");
			}
	}
	close (MIA);
} else {
	print ("------------------------------------------------------------------------\n");
	print ("No substitute_proposal.tsv file provided\n");
	print ("------------------------------------------------------------------------\n");
	die;
}
my @subs = sort keys (%hashSub);

#-------------------------------------------------------------------------------
# Gather information from the metadata.tsv file
print ("Analysing: $fileMe\n");
$n = 0;
open (MIA, "$fileMe") or die ("Can't open $fileMe\n");
open (ROB, ">outfile.tsv") or die ("Can't open outfile.tsv\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
  if ($l > 1){
    my @a = split (/\t/, $linea);
    my @b = split (/\//, $a[4]);
		if (exists $hashSub{$a[4]}){
			for (my $i = 0; $i <= $#a; $i++){
				if ($i == 4){
					print ROB ("$hashSub{$a[4]}\t");
					$substitutions{$a[4]} = $hashSub{$a[4]};
				} elsif ($i == $#a){
					print ROB ("$a[$i]\n");
				} else {
					print ROB ("$a[$i]\t");
				}
		  }
		} else {
    	print ROB ("$linea\n");
  	}
	} else {
		print ROB ("$linea\n");
	}
}

close (MIA);
my @subarray = sort keys (%substitutions);
if (@subarray > 0){
	print ("------------------------------------------------------------------------\n");
	print ("The following names were substituted, please check:\n");
	for (my $i = 0; $i <= $#subarray; $i++){
		print ("\n");
		print ("old: '$subarray[$i]'\n");
		print ("new: '$substitutions{$subarray[$i]}'\n");
	}
}
print ("\n");
print ("------------------------------------------------------------------------\n");
print ("Results are written to outfile.tsv.\n");
print ("Now run compare_names.pl.\n");
print ("See https://github.com/luisdelaye/Mexstrain/ for more details.\n");
print ("------------------------------------------------------------------------\n");
#-------------------------------------------------------------------------------
