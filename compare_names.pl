#!/usr/bin/perl

# This script check whether the names of geographic localities in metadata.tsv
# are the same as those in color_ordering.tsv.

# use
# perl compare_names.pl color_ordering.tsv metadata.tsv Country
# out: <STDOUT>, substitute_proposal.tsv


# 'Country' refers to the name of the Country whose names of divisions and locations are
# to be curated. For example: Mexico.

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

my $fileCo   = $ARGV[0]; # color_ordering.tsv file
my $fileMe   = $ARGV[1]; # metadata.tsv file
my $country  = $ARGV[2]; # the name of the country

$country =~ s/_/\s/g;

my %hashCo;              # category of geographic localities
my %country;             # Country of reference
my $hashA = {};
my %hashK = {};
my %allgc;
my %check;
my %output;
my $l = 0;
my $n = 0;
my $machy = 0;

#-------------------------------------------------------------------------------
# Check if a substitute_proposal file already exists

if (-e 'substitute_proposal.tsv'){
	print ("\n------------------------------------------------------------------------\n");
	print ("A substitute_proposal.tsv file already exists.\n");
	print ("If there are no matching names in $fileMe, its content will be replaced.\n");
	print ("Do you want to continue? (y/n)\n");
	my $answer = <STDIN>;
	if ($answer =~ /n/i){
		die;
	} else {
		system ("rm substitute_proposal.tsv\n")
	}
}

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
#-------------------------------------------------------------------------------
# Check whether there are lacking names
print ("\n------------------------------------------------------------------------\n");
print ("Part 1\n");
print ("Are there names in $fileMe lacking in $fileCo?\n");

$n = 0;
open (MIA, "$fileMe") or die ("Can't open $fileMe\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
  if ($l > 1){
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
		$allgc{$a[4]} += 1;
    if ($b[1] =~ /^$country$/i){
			# Ask if there is a name in metadata.tsv that is not found in color_ordering.tsv
      for (my $i = 0; $i <= $#b; $i++){
        if (!exists $hashCo{$b[$i]}){
					if (!exists $check{$a[4]}){
						print ("\n");
						print ("Warning! name not found in $fileCo: '$c[$i]'\n");
						$machy = 1; # This variable control whether there are lacking names
						print ("context in $fileMe: $a[4]\n");
						$output{$a[4]} = $c[$i];
						$check{$a[4]} = 1; # With this hash I control whether the name (and its geographic context) is already identified
					}
        }
      }
			# Ask if the same name is in different geographic contexts
			for (my $i = $#c; $i > 0; $i--){
				if ($c[$i] =~ /\w/){
					if ($#c == 3){
						if ($i == $#c){
							my $str = $c[0].' / '.$c[1].' / '.$c[2];
							push (@{$hashA->{$c[$i]}}, $str);
							$hashK{$c[$i]} += 1;
						} elsif ($i == ($#c -1)){
							my $str = $c[0].' / '.$c[1];
							push (@{$hashA->{$c[$i]}}, $str);
							$hashK{$c[$i]} += 1;
						} elsif ($i == ($#c -2)){
							my $str = $c[0];
							push (@{$hashA->{$c[$i]}}, $str);
							$hashK{$c[$i]} += 1;
						}
					} elsif ($#c == 2){
						if ($i == $#c){
							my $str = $c[0].' / '.$c[1];
							push (@{$hashA->{$c[$i]}}, $str);
							$hashK{$c[$i]} += 1;
						} elsif ($i == ($#c -1)){
							my $str = $c[0];
							push (@{$hashA->{$c[$i]}}, $str);
							$hashK{$c[$i]} += 1;
						}
					} elsif ($#c == 1){
						if ($i == $#c){
							my $str = $c[0];
							push (@{$hashA->{$c[$i]}}, $str);
							$hashK{$c[$i]} += 1;
						}
					}
				}
			}
    }
  }
}
close (MIA);
my @out = sort keys (%output);
if (@out > 0){
	open (ROB, ">substitute_proposal.tsv") or die ("Can't open substitute_proposal.tsv\n");
	for (my $i = 0; $i <= $#out; $i++){
		print ROB ("'$output{$out[$i]}'\t'$out[$i]'\t'$out[$i]'\n");
	}
	close (ROB);
}
#-------------------------------------------------------------------------------
# Check whether the same name is repeated in different geographic contexts
print ("\n------------------------------------------------------------------------\n");
print ("Part 2\n");
print ("Checking if the same name is repeated in different geographic contexts\n");
my $check2 = 0;
my @keysN = sort keys (%hashK);
for (my $i = 0; $i <= $#keysN; $i++){
	my %h = ();
	for (my $j = 0; $j <= $#{$hashA->{$keysN[$i]}}; $j++){
		if (exists $allgc{${$hashA->{$keysN[$i]}}[$j]}){
			if (!exists $h{${$hashA->{$keysN[$i]}}[$j]}){
				$h{${$hashA->{$keysN[$i]}}[$j]} += 1;
			}
		}
	}
	my @a = sort keys (%h);
	if ($#a > 0){
		$check2 = 1;
		print ("\nWarning! the name '$keysN[$i]' is in more than one geographic context:\n");
		for (my $j = 0; $j <= $#a; $j++){
			print ("$a[$j] / '$keysN[$i]'\n");
			my $gc = $a[$j].' / '.$keysN[$i];
				if (!exists $output{$gc}){
					open (ROB, ">>substitute_proposal.tsv") or die ("Can't open substitute_proposal.tsv\n");
					print ROB ("'$keysN[$i]'\t'$gc'\t'$gc'\n");
					close (ROB);
				}
		}
	}
}
if ($check2 == 0){
	print ("\nThere are no names repeated in different geographic contexts\n");
}
#-------------------------------------------------------------------------------
# Report the results
if ($machy == 1){
	print ("\n");
	print ("------------------------------------------------------------------------\n");
	print ("Now run substitute_names.pl.\n");
	print ("See https://github.com/luisdelaye/Mexstrain/ for more details.\n");
	print ("------------------------------------------------------------------------\n");
} else {
	print ("------------------------------------------------------------------------\n");
	print ("All names in $fileMe have a match in $fileCo\n");
	print ("See https://github.com/luisdelaye/Mexstrain/ for more details.\n");
	print ("------------------------------------------------------------------------\n");
}
#-------------------------------------------------------------------------------
