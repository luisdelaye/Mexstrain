#!/usr/bin/perl

# This script sample genomes from a Nextstrain metadata file.

# use
# perl sample_genomes_Nextstrain.pl metadata.e2.tsv nextstrain_ncov_gisaid_global_acknowledgements.tsv 'seed' 'n'
# out:
# outfile.tsv

# 'seed' is an integer used to generate random numbers. Example: 2718 and
# 'n' is the maximum number of genomes to sample per Pango lineage per month.

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

my $meta   = $ARGV[0]; # metadata.e2.tsv file
my $file   = $ARGV[1]; # nextstrain_ncov_global_metadata.tsv file
my $seed   = $ARGV[2]; # random number
my $rounds = $ARGV[3]; # rounds of selection

srand($seed);

my %dates;
my %alldates;
my %clade;
my %allclade;
my %pango;
my %allpango;
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
# Gather information from the metadata.e2.tsv file
open (MIA, "$meta") or die ("Can't open $meta\n");
while (my $linea = <MIA>){
	chomp ($linea);
  $l++;
  if ($l > 1 && $linea =~ /\w/){
    my @a = split (/\t/, $linea);
    if ($a[2] =~ /(\d{4}-\d{2})/){
      my $date = $1;
      $alldates{$a[1]} = $date;
			$allclade{$a[1]} = $a[14];
			$allpango{$a[1]} = $a[15];
    }
  }
}
close (MIA);
#-------------------------------------------------------------------------------
# Gather information from the nextstrain_ncov_gisaid_global_acknowledgements.tsv file
$l = 0;
$n = 0;
open (MIA, "$file") or die ("Can't open $file\n");
while (my $linea = <MIA>){
	chomp ($linea);
  $l++;
  if ($l > 1 && $linea =~ /\w/){
    my @a = split (/\t/, $linea);
		if (exists $alldates{$a[1]}){
    	if ($alldates{$a[1]} =~ /(\d{4}-\d{2})/){
      	my $date = $1;
      	$dates{$date}  += 1;
      	$pango{$allpango{$a[1]}} += 1;
      	$clade{$allclade{$a[1]}} += 1;
      	push(@{$hashA->{$date}{$allpango{$a[1]}}}, $a[1]);
				#print ("$a[0]\t$date\n");
    	}
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
	print ("---------------------------------------------------------\n");
	print ("---------------------------------------------------------\n");
  print ("Date.............: $kdates[$i]\n");
	print ("Number of genomes: $dates{$kdates[$i]}\n");
  for (my $j = 0; $j <= $#kpango; $j++){
    if (exists $hashA->{$kdates[$i]}{$kpango[$j]}){
			print ("\n---------------------------------------------------------\n");
			print ("Pango lineage:\t$kpango[$j]\n");
			print ("Genomes:\n");
      for (my $k = 0; $k <= $#{$hashA->{$kdates[$i]}{$kpango[$j]}}; $k++){
        if ($k < $#{$hashA->{$kdates[$i]}{$kpango[$j]}}){
          print ("${$hashA->{$kdates[$i]}{$kpango[$j]}}[$k]; ");
        } else {
          print ("${$hashA->{$kdates[$i]}{$kpango[$j]}}[$k]\n");
        }
      }
      my $s = 0;
			if ($s < $rounds){
				print ("Sampled genomes:\n")
			}
      CICLOA:
      while ($s < $rounds){
        my $retval = int(rand($#{$hashA->{$kdates[$i]}{$kpango[$j]}} +1));
        my $N = $#{$hashA->{$kdates[$i]}{$kpango[$j]}} + 1;
        #print ("\t\tselected (index: $retval; N: $N) -> (${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval])\n");
				#print ("${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval]\n");
        if (!exists $selected{${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval]}){
					print ("${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval]\n");
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
          print ("this genome was selected already: ${$hashA->{$kdates[$i]}{$kpango[$j]}}[$retval]}\n");
					#die ("run again the script but using a different seed for the random number generator\n");
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
