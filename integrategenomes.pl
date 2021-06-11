#!/usr/bin/perl

# This script integrates into one file the genomes selected for Nextstrain analysis

# use
# perl integrategenomes.pl gisaid_hcov-19_2021_##_##_##.selected.tsv nextstrain_ncov_global_metadata.selected.tsv metadata.e2.tsv sequences.fasta
# out:
# outfile.tsv

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

my $fileg = $ARGV[0]; # gisaid_hcov-19_2021_##_##_##.selected.tsv file
my $filen = $ARGV[1]; # nextstrain_ncov_global_metadata.selected.tsv file
my $filem = $ARGV[2]; # metadata.e2.tsv file
my $filef = $ARGV[3]; # sequences.fasta file

my %ids;
my %headers;

my $r = 0;
my $sec;
my $name;

my $l = 0;
my $n = 0;

#-------------------------------------------------------------------------------
# Gather information from the gisaid_hcov-19_2021_##_##_##.select.tsv file
open (MIA, "$fileg") or die ("Can't open $fileg\n");
while (my $linea = <MIA>){
	chomp ($linea);
  if ($linea =~ /(.+)/){
    my $id = $1;
    $id =~ s/\s//g;
    $ids{$id} = 1;
  }
}
close (MIA);
#-------------------------------------------------------------------------------
# Gather information from the nextstrain_ncov_global_metadata.selected.tsv file
open (MIA, "$filen") or die ("Can't open $filen\n");
while (my $linea = <MIA>){
	chomp ($linea);
  if ($linea =~ /(.+)/){
    my $id = $1;
    $id =~ s/\s//g;
    $ids{$id} = 1;
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
    }
  } else {
    print ROB ("$linea\n");
  }
}
close (ROB);
close (MIA);
#-------------------------------------------------------------------------------
# Select genomes from the sequences.fasta file

open (MIA, "$filef") or die ("No puedo abrir $filef\n");
open (ROB, ">outfile.fasta") or die ("Can't open outfile.fasta\n");
while (my $linea = <MIA>){
	#chomp ($linea);
	if ($linea =~ />/ && $r == 1){
    $name =~ s/>//;
		if (exists $headers{$name}){
      print ROB (">$name\n$sec\n");
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
  }
	$r = 0;
	$name = $sec = ();
}
close (ROB);
close (MIA);
#-------------------------------------------------------------------------------
