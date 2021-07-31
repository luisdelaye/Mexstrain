#!/usr/bin/perl

# This script concatenate tsv files downloaded from GISAID

# use
# perl concatenatetsvfiles.pl gisaid_hcov-19_2021_
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

my $filename = $ARGV[0];

my %hash;

my $n = 0;
my $header;
my $ids = 0;

#-------------------------------------------------------------------------------
# Concatenate files

my @files = glob("$filename*.tsv");

open (ROB, ">outfile.tsv") or die ("Can't open outfile.tsv\n");
foreach my $f (@files){
  $n++;
  print ("$f\n");
  if ($n == 1){
    my $l = 0;
    open (MIA, "$f") or die ("Can't open $f\n");
    while (my $linea = <MIA>){
      $l++;
      if ($l == 1){
        $header = $linea;
        print ROB ("$linea");
      } else {
        my @a = split (/\t/, $linea);
        if (!exists $hash{$a[1]}){
          $hash{$a[1]} = 1;
          print ROB ("$linea");
          $ids++;
        }
      }
    }
    close (MIA);
  } else {
    my $l = 0;
    open (MIA, "$f") or die ("Can't open $f\n");
    while (my $linea = <MIA>){
      $l++;
      if ($l > 1){
        my @a = split (/\t/, $linea);
        if (!exists $hash{$a[1]}){
          $hash{$a[1]} = 1;
          print ROB ("$linea");
          $ids++;
        }
      }
    }
    close (MIA);
  }
}
close (ROB);
print ("Number of files..: $n\n");
print ("Number of genomes: $ids\n");
