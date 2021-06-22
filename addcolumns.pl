#!/usr/bin/perl

# This script adds columns to the metadata.selected.tsv file

# use
# perl addcolumns.pl metadata.selected.tsv

# out: outfile.tsv

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

my $file = $ARGV[0]; # metadata.selected.tsv

my $l = 0;

my $date_submitted;
my $region_exposure;
my $country_exposure;
my $division_exposure;

#-----------------------------------------------------------------------------------------
# Add regions of exposure columns
open (MIA, "$file") or die ("Can't open file $file\n");
open (ROB, ">outfile.tsv") or die ("Can't open file outfile.tsv\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
	if ($l > 1){
		my @a = split (/\t/, $linea);
    for (my $i = 0; $i <= $#a; $i++){
      if ($i == 3){
        $region_exposure = $a[$i];
        print ROB ("$a[$i]\t");
      } elsif ($i == 4){
        $country_exposure = $a[$i];
        print ROB ("$a[$i]\t");
      } elsif ($i == 5){
        $division_exposure = $a[$i];
        print ROB ("$a[$i]\t");
      } elsif ($i == 6){
        print ROB ("$a[$i]\t$region_exposure\t$country_exposure\t$division_exposure\t");
      } elsif ($i == $#a){
        print ROB ("$a[$i]\n");
      } else {
        print ROB ("$a[$i]\t");
      }
    }
	} else {
    my @a = split (/\t/, $linea);
    for (my $i = 0; $i <= $#a; $i++){
      if ($i == 6){
        print ROB ("$a[$i]\tregion_exposure\tcountry_exposure\tdivision_exposure\t");
      } elsif ($i == $#a){
        print ROB ("$a[$i]\n");
      } else {
        print ROB ("$a[$i]\t");
      }
    }
  }
}
close (ROB);
close (MIA);
#die ("bien!\n");
#-----------------------------------------------------------------------------------------
# Add date_submitted column
$l = 0;
open (MIA, "outfile.tsv") or die ("Can't open file outfile.tsv\n");
open (ROB, ">outfile2.tsv") or die ("Can't open file outfile2.tsv\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
	if ($l > 1){
		my @a = split (/\t/, $linea);
		if ($a[0] =~ /\|\d{4}-\d{2}[-\d]*\|(\d{4}-\d{2}-\d{2})$/){
			$date_submitted = $1;
		} else {
      die ("pattern 1 failed:\n$linea\n");
    }
    for (my $i = 0; $i <= ($#a+1); $i++){
      if ($i <= $#a){
        print ROB ("$a[$i]\t");
      } else {
        print ROB ("$date_submitted\n");
      }
    }
	} else {
    my @a = split (/\t/, $linea);
    for (my $i = 0; $i <= ($#a+1); $i++){
      if ($i <= $#a){
        print ROB ("$a[$i]\t");
      } else {
        print ROB ("date_submitted\n");
      }
    }
  }

}
close (ROB);
close (MIA);
system ("mv outfile2.tsv outfile.tsv");
#my $pausa = <STDIN>;
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
			if ($i == 15){
				# VOC
				if ($a[$i] eq 'B.1.1.7'){
					print ROB ("$a[$i]\t\tAlpha\t");
				} elsif ($a[$i] eq 'B.1.351'){
					print ROB ("$a[$i]\t\tBeta\t");
				} elsif ($a[$i] eq 'P.1'){
					print ROB ("$a[$i]\t\tGamma\t");
				} elsif ($a[$i] eq 'B.1.617.2'){
					print ROB ("$a[$i]\t\tDelta\t");
				# VOI
				} elsif ($a[$i] eq 'B.1.427'){
					print ROB ("$a[$i]\tEpsilon\t\t");
				} elsif ($a[$i] eq 'B.1.429'){
					print ROB ("$a[$i]\tEpsilon\t\t");
				} elsif ($a[$i] eq 'P.2'){
					print ROB ("$a[$i]\tZeta\t\t");
				} elsif ($a[$i] eq 'B.1.525'){
					print ROB ("$a[$i]\tEta\t\t");
				} elsif ($a[$i] eq 'P.3'){
					print ROB ("$a[$i]\tTheta\t\t");
				} elsif ($a[$i] eq 'B.1.526'){
					print ROB ("$a[$i]\tIota\t\t");
				} elsif ($a[$i] eq 'B.1.617.1'){
					print ROB ("$a[$i]\tKappa\t\t");
				} elsif ($a[$i] eq 'C.37'){
					print ROB ("$a[$i]\tLambda\t\t");
				} else {
					print ROB ("$a[$i]\t\t\t");
				}
			} elsif ($i == $#a){
				print ROB ("$a[$i]\n");
			} else {
	      		print ROB ("$a[$i]\t");
	    	}
	    }
	} else {
		my @a = split (/\t/, $linea);
		for (my $i = 0; $i <= $#a; $i++){
			if ($i == 15){
				print ROB ("$a[$i]\tVOI\tVOC\t");
			} elsif ($i == $#a){
				print ROB ("$a[$i]\n");
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
