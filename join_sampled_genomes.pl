#!/usr/bin/perl

# This script joins into a single file those genomes sampled from GIDAID and Nextstrain global analysis for a novel Nextstrain analysis.

# use
# perl join_sampled_genomes.pl gisaid_hcov-19_2022_##_##.sampled.tsv nextstrain_ncov_gisaid_global.sampled.tsv metadata.e2.tsv sequences.fasta
# out:
# outfile.tsv, outfile.fasta

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

my $fileg = $ARGV[0]; # gisaid_hcov-19_2022_##_##.sampled.tsv file
my $filen = $ARGV[1]; # nextstrain_ncov_gisaid_global.sampled.tsv file
my $filem = $ARGV[2]; # metadata.e2.tsv file
my $filef = $ARGV[3]; # sequences.fasta file

my %ids;
my %headers;
my %notfound;

my $r = 0;
my $sec;
my $name;

my $l = 0;
my $n = 0;

my $n_M = 0;
my $n_S = 0;

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
if (-e 'outfile.fasta'){
	print ("\n------------------------------------------------------------------------\n");
	print ("A file named outfile.fasta already exists.\n");
	print ("If you continue with the analysis, its content will be replaced.\n");
	print ("Do you want to continue? (y/n)\n");
	my $answer = <STDIN>;
	if ($answer =~ /n/i){
		die;
	} else {
		system ("rm outfile.fasta\n")
	}
}

#-------------------------------------------------------------------------------
# Gather information from the gisaid_hcov-19_2022_##_##.sampled.tsv file

open (MIA, "$fileg") or die ("Can't open $fileg\n");
while (my $linea = <MIA>){
	chomp ($linea);
  if ($linea =~ /(.+)/){
    my $id = $1;
    $id =~ s/\s//g;
    $ids{$id} = 1;
		$notfound{$id} = 0;
  }
}
close (MIA);

#-------------------------------------------------------------------------------
# Gather information from the nextstrain_ncov_gisaid_global.sampled.tsv file

open (MIA, "$filen") or die ("Can't open $filen\n");
while (my $linea = <MIA>){
	chomp ($linea);
  if ($linea =~ /(.+)/){
    my $id = $1;
    $id =~ s/\s//g;
    $ids{$id} = 1;
		$notfound{$id} = 0;
		#print ("($id)\n");
  }
}
close (MIA);

#-------------------------------------------------------------------------------
# Select genomes from the metadata.e2.tsv file

open (MIA, "$filem") or die ("Can't open $filem\n");
open (ROB, ">outfile.tsv") or die ("Can't open outfile.tsv\n");
while (my $linea = <MIA>){
	chomp ($linea);
  $l++;
  if ($l > 1){
    my @a = split (/\t/, $linea);
    if (exists $ids{$a[1]}){
      print ROB ("$linea\n");
      $headers{$a[0]} = $a[1];
			$notfound{$a[1]} = 1;
			$n_M++;
    }
  } else {
    print ROB ("$linea\n");
  }
}
close (ROB);
close (MIA);

#-------------------------------------------------------------------------------
# Select genomes from the sequences.fasta file

open (MIA, "$filef") or die ("Can't open $filef\n");
open (ROB, ">outfile.fasta") or die ("Can't open outfile.fasta\n");
while (my $linea = <MIA>){
	#chomp ($linea);
	if ($linea =~ />/ && $r == 1){
    $name =~ s/>//;
		if (exists $headers{$name}){
      print ROB (">$name\n$sec\n");
			$notfound{$headers{$name}} = 2;
			$n_S++;
    }
		$r = 0;
		$name = $sec = ();
	}
	if ($linea !~ />/ && $r == 1){
		$sec = $sec.$linea;
	}
	if ($linea =~ />/ && $r == 0){
    chomp ($linea);
		$name = $linea;
		$r = 1;
	}
}
if ($r == 1){
  $name =~ s/>//;
  if (exists $headers{$name}){
    print ROB (">$name\n$sec\n");
		$notfound{$headers{$name}} = 2;
		$n_S++;
  }
	$r = 0;
	$name = $sec = ();
}
close (ROB);
close (MIA);

#-------------------------------------------------------------------------------
# Report the number of sequences

my @anf = sort keys (%notfound);
my $q = 0;
for (my $i = 0; $i <= $#anf; $i++){
	if ($notfound{$anf[$i]} != 2){
		$q = 1;
	}
}
if ($q == 0){
	print ("\n");
	print ("------------------------------------------------------------------------\n");
	print ("Number of entries in outfile.tsv....: $n_M\n");
	print ("Number of sequences in outfile.fasta: $n_S\n");
	print ("------------------------------------------------------------------------\n");
} else {
	print ("\n");
	print ("------------------------------------------------------------------------\n");
	print ("The following sequences were not found in $filef\n\n");
	for (my $i = 0; $i <= $#anf; $i++){
		if ($notfound{$anf[$i]} == 1){
			print ("$anf[$i]\n");
		}
	}
	print ("\n");
	print ("------------------------------------------------------------------------\n");
	print ("Number of entries in outfile.tsv....: $n_M\n");
	print ("Number of sequences in outfile.fasta: $n_S\n");
	print ("------------------------------------------------------------------------\n");
}
#-------------------------------------------------------------------------------
