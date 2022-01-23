#!/usr/bin/perl

# This script sample genomes for Nextstrain analysis.

# use
# perl sample_genomes.pl gisaid_hcov-19_2021_##_##.e1.tsv 'seed' 'n'
# out:
# outfile.tsv

# 'seed' is an integer used to generate random numbers. Example: 2718
# and 'n' is the number of genomes to select per Pango lineage per month.

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

my $file   = $ARGV[0]; # gisaid_hcov-19_2021_##_##.e1.tsv file
my $seed   = $ARGV[1]; # random number
my $rounds = $ARGV[2]; # rounds of selection

srand($seed);

my %dates;
my %clade;
my %pango;
my $hashA = {};
my %selected;
my @selected;

my $l = 0;
my $n = 0;
my $N = 0;

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
# Gather information from the gisaid_hcov-19_2021_##_##.e1.tsv file
open (MIA, "$file") or die ("Can't open $file\n");
while (my $linea = <MIA>){
	chomp ($linea);
  $l++;
  if ($l > 1 && $linea =~ /\w/){
    my @a = split (/\t/, $linea);
    if ($a[2] =~ /(\d{4}-\d{2})/){
      my $date = $1;
      $dates{$date}  += 1;
      $pango{$a[14]} += 1;
      $clade{$a[15]} += 1;
      push(@{$hashA->{$date}{$a[14]}}, $a[1]);
    }
  }
}
close (MIA);
my @kdates = sort keys (%dates);
my @kpango = sort keys (%pango);
my @kclade = sort keys (%clade);
print ("\n------------------------------------------------------------------------\n");
print ("Number of genomes per collection date\n\n");
for (my $i = 0; $i <= $#kdates; $i++){
  print ("$kdates[$i]\t$dates{$kdates[$i]}\n");
}
print ("\n------------------------------------------------------------------------\n");
print ("Number of genomes per Pangolin lineage\n\n");
for (my $i = 0; $i <= $#kpango; $i++){
  print ("$kpango[$i]\t$pango{$kpango[$i]}\n");
}
print ("\n------------------------------------------------------------------------\n");
print ("Number of genomes per clade\n\n");
for (my $i = 0; $i <= $#kclade; $i++){
  print ("$kclade[$i]\t$clade{$kclade[$i]}\n");
}
#-------------------------------------------------------------------------------
# Select genomes per month per Pango lineage
print ("\n------------------------------------------------------------------------\n");
print ("Sampling genomes, per Pango linage per month\n\n");
for (my $i = 0; $i <= $#kdates; $i++){
  print ("$kdates[$i]\t$dates{$kdates[$i]}\n");
  for (my $j = 0; $j <= $#kpango; $j++){
    if (exists $hashA->{$kdates[$i]}{$kpango[$j]}){
      print ("\t$kpango[$j]\n");
      #for (my $k = 0; $k <= $#{$hashA->{$kdates[$i]}{$kpango[$j]}}; $k++){
      #  if ($k < $#{$hashA->{$kdates[$i]}{$kpango[$j]}}){
      #    print ("${$hashA->{$kdates[$i]}{$kpango[$j]}}[$k]; ");
      #  } else {
      #    print ("${$hashA->{$kdates[$i]}{$kpango[$j]}}[$k]\n");
      #  }
      #}
      my $s = 0;
      CICLOA:
      while ($s < $rounds){
        my $retval = int(rand($#{$hashA->{$kdates[$i]}{$kpango[$j]}}));
        my $N = $#{$hashA->{$kdates[$i]}{$kpango[$j]}} + 1;
        #print ("\t\tselected (index: $retval; N: $N) -> (${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval])\n");
				print ("\t\tsampled -> (${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval])\n");
        if (!exists $selected{${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval]}){
          $selected{${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval]} = 1;
          push (@selected, ${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval]);
          $s++;
          my @tmp = @{$hashA->{$kdates[$i]}{$kpango[$j]}};
          my $idt = ${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval];
          @{$hashA->{$kdates[$i]}{$kpango[$j]}} = ();
          for (my $k = 0; $k <= $#tmp; $k++){
            if ($tmp[$k] !~ /$idt/){
              push (@{$hashA->{$kdates[$i]}{$kpango[$j]}}, $tmp[$k]);
            }
          }
        } else {
          print ("this genome was already selected: ${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval]}\n");
					die ("run again the script but using a different random number generator\n");
        }
        my $asize = @{$hashA->{$kdates[$i]}{$kpango[$j]}};
        if ($asize == 0){
          last (CICLOA);
        }
      }
    }
  }
}
open (ROB, ">outfile.tsv") or die ("Can't open file outfile.tsv\n");
for (my $i = 0; $i <= $#selected; $i++){
  print ROB ("$selected[$i]\n");
	$N++;
}
close (ROB);
print ("\n");
print ("------------------------------------------------------------------------\n");
print ("Number of genomes sampled: $N\n");
print ("------------------------------------------------------------------------\n");
#die ("bien!\n");
#-------------------------------------------------------------------------------
