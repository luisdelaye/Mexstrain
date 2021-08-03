#!/usr/bin/perl

# This script extract sequences for a phylogenetic analysis for Microreact

# use
# perl exstactsecs.pl outfile_subset.tsv alignment.fasta

# out: outfile_subset.fasta

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

my $file1 = $ARGV[0]; # outfile_subset.tsv
my $file2 = $ARGV[1]; # fasta file

my %seqs;

my $l = 0;

#-------------------------------------------------------------------------------
# Gater sequence names
open (MIA, "$file1") or die ("Can't open $file1\n");
while (my $linea = <MIA>){
  chomp ($linea);
  $l++;
  if ($l > 1){
    my @a = split (/\t/, $linea);
    $seqs{$a[0]} = 1;
    #print ("($a[0])\n");
  }
}
close (MIA);
#-------------------------------------------------------------------------------
# Exstract sequences

my $r = 0;
my $sec;
my $name;

open (MIA, "$file2") or die ("No puedo abrir $file2\n");
open (ROB, ">outfile") or die ("No puedo abrir outfile\n");
while (my $linea = <MIA>){
	#chomp ($linea);
	if ($linea =~ />/ && $r == 1){
		if (exists $seqs{$name}){
      print ("($name)\n");
      print ROB (">$name\n");
      print ROB ("$sec\n");
    }
		$r = 0;
		$name = $sec = ();
	}
	if ($linea !~ />/ && $r == 1){
		$sec = $sec.$linea;
	}
	if ($linea =~ />/ && $r == 0){
		$name = $linea;
    chomp ($name);
    $name =~ s/>//;
    #print ("($name)\n");
		$r = 1;
	}
}
if ($r == 1){
  if (exists $seqs{$name}){
    print ROB (">$name\n");
    print ROB ("$sec\n");
  }
	$r = 0;
	$name = $sec = ();
}
close (ROB);
close (MIA);
#-------------------------------------------------------------------------------
