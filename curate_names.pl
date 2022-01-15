#!/usr/bin/perl

# UPDATE THIS

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

my %hashCo;                 # category of geographic localities
my %region;
my %country;
my %division;
my %location;
my %hashSub;                # names to be substituted
my %lacking;
my %check;
my %substitutions;
my $substitutions2 = {};
my %check2;

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
	print ("------------------------------------------------------------------------\n");
	print ("A substitute.tsv file was provided: $subsfile\n");
	print ("------------------------------------------------------------------------\n");
	open (MIA, "$subsfile") or die ("Can't open $subsfile\n");
	while (my $linea = <MIA>){
		chomp ($linea);
	    my @a = split (/\t/, $linea);
			$a[0] =~ tr/A-Z/a-z/;
			$a[0] =~ s/^\s+//;
      $a[0] =~ s/\s+$//;
			$a[1] =~ tr/A-Z/a-z/;
			$a[1] =~ s/^\s+//;
      $a[1] =~ s/\s+$//;
	    $a[2] =~ tr/A-Z/a-z/;
			$a[2] =~ s/^\s+//;
      $a[2] =~ s/\s+$//;
			my $k = $a[0].' -join- '.$a[1];
			$hashSub{$k} = $a[2];
	}
	close (MIA);
} else {
	print ("------------------------------------------------------------------------\n");
	print ("No substitute.tsv file provided\n");
	print ("------------------------------------------------------------------------\n");
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
		my @c = split (/\//, $a[4]);
    for (my $i = 0; $i <= $#b; $i++){
      $b[$i] =~ s/^\s+//;
      $b[$i] =~ s/\s+$//;
      $b[$i] =~ tr/A-Z/a-z/;
			$c[$i] =~ s/^\s+//;
      $c[$i] =~ s/\s+$//;
    }
    my $mex = ();
    if ($b[1] =~ /^$country$/i){
      my $sino = 0;
			# Ask if there is a name in metadata.tsv that is not found in color_ordering.tsv
      for (my $i = 0; $i <= $#b; $i++){
        if (!exists $hashCo{$b[$i]}){
          $sino = 1;
        }
      }
			# If there ir a name in metadata.tsv that is not found in color_ordering.tsv
      if ($sino == 1){
				# Check that the name (including its geographic context) is identified as lacking in color_ordering.tsv for the first time
      	if (!exists $check{$a[4]}){
					print ("\n");
					# Identify (again) the lacking name and print
	      	for (my $i = 0; $i <= $#b; $i++){
	        	if (!exists $hashCo{$b[$i]}){
							print ("Warning! name not found in $fileCo: '$c[$i]'\n");
							# Create a key ($k) formed by the laking name in its geographic context
							my $lck = ();
							if ($i > 0){
								$lck = $c[$i-1].' / '.$c[$i];
							} else {
								$lck = 'NA / '.$c[$i];
							}
							$lacking{$lck} = $c[$i]; # This hahs is used to report which names alre lacking
	        	  $machy = 1; # This variable control whether there are lacking names
	        	}
	      	}
					print ("context in $fileMe: $a[4]\n");
	      	$check{$a[4]} = 1; # With this hash I control whether the name (and its geographic context) is already identified
	    	}
      }
			# Here I replace the names of the locations if a substitution file is provided
			for (my $i = 0; $i <= $#b; $i++){
				if ($sino == 1){
        	for (my $j = 0; $j <= $#subs; $j++){
						my @d = split (/ -join- /, $subs[$j]);
						# Here I ask whether the name in metadata.tsv $b[$i] matches the name in the substitute.tsv file $d[1]
        		if ($b[$i] =~ /$d[1]/){
							# Here I ask if the parent geographic localities are the same
							my $k  = $b[$i-1].' -join- '.$b[$i];
							#print ("$k =~ $subs[$j]\n");
							if ($k =~ $subs[$j]){
								#print ("bingo!\n");
         	 			$b[$i] = $hashSub{$subs[$j]};
					 			$substitutions{$subs[$j]} = $hashSub{$subs[$j]};
					 			if (!exists $check2{$a[4]}){
					 				push (@{$substitutions2->{$subs[$j]}}, $a[4]);
									$check2{$a[4]} = 1;
					 			}
							}
        		}
        	}
				}
				if ($i == 0){
          $mex = $b[$i];
        } else {
          $mex = $mex.' / '.$b[$i];
        }
      }
			# Here I print the new names to outfile.tsv
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
my @subarray = sort keys (%substitutions);
if (@subarray > 0){
	print ("\n------------------------------------------------------------------------\n");
	print ("\The following names were substituted, please check:\n");
	for (my $i = 0; $i <= $#subarray; $i++){
		my @e = split (/ -join- /, $subarray[$i]);
		print ("\n($e[1]) was substituded by ($substitutions{$subarray[$i]})\n");
		print ("in the following geographic location(s):\n");
		for (my $j = 0; $j <= $#{$substitutions2->{$subarray[$i]}}; $j++){
			print ("${$substitutions2->{$subarray[$i]}}[$j]\n");
		}
	}
}
if ($machy == 1){
	my @lack = sort keys (%lacking);
	print ("\n------------------------------------------------------------------------\n");
	print ("The following names don't match any name in the color_ordering.tsv file:\n\n");
	my %repe = ();
	for (my $i = 0; $i <= $#lack; $i++){
		print ("'$lack[$i]'\n");
		my @a = split (/ \/ /, $lack[$i]);
		$repe{$a[1]} += 1;
	}
	print ("\nWarning! The following locations share name:\n");
	for (my $i = 0; $i <= $#lack; $i++){
		my @a = split (/ \/ /, $lack[$i]);
		if ($repe{$a[1]} > 1){
			print ("'$lack[$i]'\n");
		}
	}
	print ("\n");
	print ("------------------------------------------------------------------------\n");
	print ("Results are written to outfile.tsv.\n");
	print ("See https://github.com/luisdelaye/Mexstrain/ for more details.\n");
	print ("------------------------------------------------------------------------\n");
} else {
	print ("All names in $fileMe have a match in $fileCo\n");
}
#die ("bien!\n");
#-------------------------------------------------------------------------------
