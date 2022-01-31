#!/usr/bin/perl

# This script adds columns to the metadata.sampled.tsv file.

# use
# perl addcolumns.pl metadata.sampled.tsv

# out: outfile.tsv

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

my $file = $ARGV[0]; # metadata.sampled.tsv

my $l = 0;

my $date_submitted;
my $region_exposure;
my $country_exposure;
my $division_exposure;

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
system ("cp $file outfile.tsv");

#-----------------------------------------------------------------------------------------
# Add VOC and VOI
$l = 0;
open (MIA, "outfile.tsv") or die ("Can't open file outfile.tsv\n");
open (ROB, ">outfile2.tsv") or die ("Can't open file outfile2.tsv\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
	if ($l > 1){
		my @a = split (/\t/, $linea);
		for (my $i = 0; $i <= $#a; $i++){
			if ($i == $#a){
				#-----------------------------------------------------------------------
				# Here you can modify the options to add the column you want
				# VOC
				if ($a[15] eq 'B.1.1.7'){
					print ROB ("$a[$i]\tAlpha\n");
				} elsif ($a[15] eq 'B.1.351'){
					print ROB ("$a[$i]\tBeta\n");
				} elsif ($a[15] eq 'P.1'){
					print ROB ("$a[$i]\tGamma\n");
				} elsif ($a[15] eq 'B.1.617.2' || $a[15] =~ /^AY\.[\d\.]+$/){
					print ROB ("$a[$i]\tDelta\n");
				} elsif ($a[15] eq 'B.1.1.529' || $a[15] eq 'BA.1' || $a[15] eq 'BA.1.1'
				 			|| $a[15] eq 'BA.2' || $a[15] eq 'BA.3'){
					print ROB ("$a[$i]\tOmicron\n");
				} else {
					print ROB ("$a[$i]\tother\n");
				}
				#-----------------------------------------------------------------------
			} else {
	      	print ROB ("$a[$i]\t");
	    }
	  }
	} else {
		my @a = split (/\t/, $linea);
		for (my $i = 0; $i <= $#a; $i++){
			if ($i == $#a){
				print ROB ("$a[$i]\tVOC\n");
			} else {
				print ROB ("$a[$i]\t");
			}
		}
  }
}
close (ROB);
close (MIA);
system ("mv outfile2.tsv outfile.tsv");
#my $pausa = <STDIN>;
#-----------------------------------------------------------------------------------------
