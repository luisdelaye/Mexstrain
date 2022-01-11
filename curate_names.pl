#!/usr/bin/perl

# This script curate the name of locations of the metadata.tsv file for Nextstrain

# use
# perl curate_names.pl color_ordering.tsv metadata.tsv Country substitute.tsv
# out:
# outfile.tsv

# 'Country' refers to the name of the Country whose names of divisions and locations are
# to be curated. For example: Mexico.

# 'substitute.tsv' is a text file containing the names of the geographic places to be 
# substituted. In the first column write the name to be substituted. In the second column
# write the new name. The columns must be separated by tabs. Write all names in lowercase.

# Example of a substitute.tsv file:
# state of mexico	estado de mexico
# coahuila de zaragoza	coahuila
# ciudad de mexico	mexico city
# yucat	yucatan

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
#-------------------------------------------------------------------------------
# Global variables

my $fileCo   = $ARGV[0]; # color_ordering.tsv file
my $fileMe   = $ARGV[1]; # metadata.tsv file
my $country  = $ARGV[2]; # the name of the country
my $subsfile = $ARGV[3]; # the name of the file with the names to substitute

my %hashCo;
my %region;
my %country;
my %division;
my %location;
my %hashSub;
my %lacking;
my %check;

my $l = 0;
my $n = 0;
my $machy = 0;

#-------------------------------------------------------------------------------
# Gather information from the color_ordering.tsv file
open (MIA, "$fileCo") or die ("Can't open $fileCo\n");
while (my $linea = <MIA>){
	chomp ($linea);
  if ($linea !~ /#/ && $linea =~ /\w/){
    my @a = split (/\t/, $linea);
    $a[1] =~ tr/A-Z/a-z/;
    $hashCo{$a[1]} = $a[0] if ($a[0] ne 'recency');
  }
}
close (MIA);
my @geo = sort keys (%hashCo);
#die ("bien!\n");
#-------------------------------------------------------------------------------
# Gather information from the substitution.tsv file
if (-e $subsfile){
	open (MIA, "$subsfile") or die ("Can't open $subsfile\n");
	while (my $linea = <MIA>){
		chomp ($linea);
	    my @a = split (/\t/, $linea);
	    $a[0] =~ tr/A-Z/a-z/;
	    $a[1] =~ tr/A-Z/a-z/;
	    $hashSub{$a[0]} = $a[1];
	}
	close (MIA);
} else {
	print ("No substitute.tsv file provided\n");
	#my $pausa = <STDIN>;
} 
my @subs = sort keys (%hashSub);
#die ("bien!\n");
#-------------------------------------------------------------------------------
# Gather information from the metadata.tsv file
$n = 0;
open (MIA, "$fileMe") or die ("Can't open $fileMe\n");
open (ROB, ">outfile.tsv") or die ("Can't open outfile.tsv\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
  if ($l > 1){
    #print ("-----\n");
    my @a = split (/\t/, $linea);
    my @b = split (/\//, $a[4]);
    for (my $i = 0; $i <= $#b; $i++){
      $b[$i] =~ s/^\s+//;
      $b[$i] =~ s/\s+$//;
      $b[$i] =~ tr/A-Z/a-z/;
    }
    my $mex = ();
    if ($b[1] =~ /^$country$/i){
      # Here I replace the names of the locations if a substitution file is provided
      for (my $i = 0; $i <= $#b; $i++){
        for (my $j = 0; $j <= $#subs; $j++){
        	if ($b[$i] =~ /$subs[$j]/){
         	 $b[$i] = $hashSub{$subs[$j]};
        	}
        }
        if ($i == 0){
          $mex = $b[$i];
        } else {
          $mex = $mex.' / '.$b[$i];
        }
      }
      my $sino = 0;
      #print ("\n$a[4]\n$mex\n");
      for (my $i = 0; $i <= $#b; $i++){
        if (!exists $hashCo{$b[$i]}){
          #print (" ($b[$i]!) ");
          $sino = 1;
        } else {
          #print (" ($b[$i]) ");
        }
      }
      if ($sino == 1){
      	if (!exists $check{$a[4]}){
	      	print ("\nnames in metadata.tsv: $a[4]\n");
	      	print ("names in lowercase...: $mex\n");
	      	for (my $i = 0; $i <= $#b; $i++){
	        	if (!exists $hashCo{$b[$i]}){
	        	  print ("Warning! name not found in $fileCo: '$b[$i]'\n");
	        	  $lacking{$b[$i]} = 1;
	        	  $machy = 1;
	        	}	
	      	}
	      	$check{$a[4]} = 1;
	      	#my $pausa = <STDIN>;
	    }
      }
      $a[4] = $mex;
      for (my $i = 0; $i <= $#a; $i++){
        if ($i < $#a){
          print ROB ("$a[$i]\t");
        } else {
          print ROB ("$a[$i]\n");
        }
      }
      #my $pausa = <STDIN>;
    } else {
      print ROB ("$linea\n");
    }
  } else {
    print ROB ("$linea\n");
  }
}
close (MIA);
#print ("$n\n");
if ($machy == 1){
	my @lack = sort keys (%lacking);
	print ("\n------------------------------------------------------------------------\n");
	print ("The following names don't match any name in the color_ordering.tsv file:\n\n");
	for (my $i = 0; $i <= $#lack; $i++){
		print ("'$lack[$i]'\n");
	}
	print ("\n");
	print ("------------------------------------------------------------------------\n");
	print ("Provide a substitution.tsv file or add the names to color_ordering.tsv.\n");
	print ("See https://github.com/luisdelaye/Mexstrain/ for more details.\n");
	print ("------------------------------------------------------------------------\n");
} else {
	print ("All names in $fileMe have a match in $fileCo\n");
}
#die ("bien!\n");
#-------------------------------------------------------------------------------
