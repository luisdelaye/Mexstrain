#!/usr/bin/perl

# This script creates a table for Microreact.

# use
# perl create_microreact_all.pl lat_longs.e1.tsv metadata.sampled.tsv Mexico
# out: outfile_all.tsv

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

my $file1   = $ARGV[0]; # lat_longs.tsv
my $file2   = $ARGV[1]; # metadata.sampled.tsv
my $Country = $ARGV[2]; # Country of selection

$Country =~ s/_/\s/g;

my $l = 0;

my %seq;

my %location_lat;
my %division_lat;
my %country_lat;
my %region_lat;
my %location_lon;
my %division_lon;
my %country_lon;
my %region_lon;

#-------------------------------------------------------------------------------
# Check if an outfile_all.tsv file already exists

if (-e 'outfile_all.tsv'){
	print ("\n------------------------------------------------------------------------\n");
	print ("A file named outfile_all.tsv already exists.\n");
	print ("If you continue with the analysis, its content will be replaced.\n");
	print ("Do you want to continue? (y/n)\n");
	my $answer = <STDIN>;
	if ($answer =~ /n/i){
		die;
	} else {
		system ("rm outfile_all.tsv\n")
	}
}

#-----------------------------------------------------------------------------------------
# Save in a hash the information of latitude and longitude
open (MIA, "$file1") or die ("Can't open file $file1\n");
while (my $linea = <MIA>){
  chomp ($linea);
	my @a = split (/\t/, $linea);
  #print ("($a[0])\t($a[1])\t($a[2])\t($a[3])\n");
  if ($a[0] =~ /location/){
    $location_lat{$a[1]} = $a[2];
    $location_lon{$a[1]} = $a[3];
  } elsif ($a[0] =~ /division/){
    $division_lat{$a[1]} = $a[2];
    $division_lon{$a[1]} = $a[3];
  } elsif ($a[0] =~ /country/){
    $country_lat{$a[1]} = $a[2];
    $country_lon{$a[1]} = $a[3];
  } elsif ($a[0] =~ /region/){
    $region_lat{$a[1]} = $a[2];
    $region_lon{$a[1]} = $a[3];
  }
}
close (MIA);
#die ("bien!\n");
#-----------------------------------------------------------------------------------------
# Create the file for microreact
open (MIA, "$file2") or die ("Can't open file $file2\n");
open (ROB, ">outfile_all.tsv") or die ("Can't open file outfile_all.tsv\n");
print ROB ("id\tlatitude\tlongitude\tyear\tmonth\tday\tvariant\tvariant__color\n");
while (my $linea = <MIA>){
  chomp ($linea);
  $l++;
  my @a = split (/\t/, $linea);
  if ($l > 1){
    if ($a[6] =~ /\w/ && $a[0] =~ /hCoV-19\/$Country\//){
      my @b = split (/-/, $a[2]);
      my $day   = ();
      my $month = ();
      my $year  = ();
      if ($b[0] !~ /\d/){
        $year = '?';
      } else {
        $year = $b[0];
      }
      if ($b[1] !~ /\d/){
        $month = '?';
      } else {
        $month = $b[1];
      }
      if ($b[2] !~ /\d/){
        $day = '?';
      } else {
        $day = $b[2];
      }
      if (1 == 1){
        my $v  = 'other';
        my $vc = '#A5A9A9';
        if ($a[15] eq 'B.1.1.7'){
          $v  = 'Alpha';
          $vc = '#F5F507';
        } elsif ($a[15] eq 'B.1.351'){
          $v  = 'Beta';
          $vc = '#F507F5';
        } elsif ($a[15] eq 'P.1'){
          $v  = 'Gamma';
          $vc = '#07F507';
        } elsif ($a[15] eq 'B.1.617.2' || $a[15] =~ /^AY\.[\d\.]+$/){
          $v  = 'Delta';
          $vc = '#0707F5';
        } elsif ($a[15] eq 'B.1.1.529' || $a[15] eq 'BA.1' ||
                 $a[15] eq 'BA.1.1' || $a[15] eq 'BA.2' ||
                 $a[15] eq 'BA.2'){
          $v  = 'Omicron';
          $vc = '#F50707';
        }
        #print ("$a[0]\t$a[6]\t$location_lat{$a[6]}\t$location_lon{$a[6]}\t$year\t$month\t$day\n");
        print ROB ("$a[0]\t$location_lat{$a[6]}\t$location_lon{$a[6]}\t$year\t$month\t$day\t$v\t$vc\n"); # if ($day ne '?');
      }
    } elsif ($a[5] =~ /\w/ && $a[0] =~ /hCoV-19\/$Country\//){
      my @b = split (/-/, $a[2]);
      my $day   = ();
      my $month = ();
      my $year  = ();
      if ($b[0] !~ /\d/){
        $year = '?';
      } else {
        $year = $b[0];
      }
      if ($b[1] !~ /\d/){
        $month = '?';
      } else {
        $month = $b[1];
      }
      if ($b[2] !~ /\d/){
        $day = '?';
      } else {
        $day = $b[2];
      }
      if (1 == 1){
        my $v  = 'other';
        my $vc = '#A5A9A9';
        if ($a[15] eq 'B.1.1.7'){
          $v  = 'Alpha';
          $vc = '#F5F507';
        } elsif ($a[15] eq 'B.1.351'){
          $v  = 'Beta';
          $vc = '#F507F5';
        } elsif ($a[15] eq 'P.1'){
          $v  = 'Gamma';
          $vc = '#07F507';
        } elsif ($a[15] eq 'B.1.617.2'){
          $v  = 'Delta';
          $vc = '#0707F5';
        } elsif ($a[15] eq 'B.1.1.529' || $a[15] eq 'BA.1' ||
                 $a[15] eq 'BA.1.1' || $a[15] eq 'BA.2' ||
                 $a[15] eq 'BA.2'){
          $v  = 'Omicron';
          $vc = '#F50707';
        }
        #print ("$a[0]\t$a[5]\t$division_lat{$a[5]}\t$division_lon{$a[5]}\t$year\t$month\t$day\n");
        print ROB ("$a[0]\t$division_lat{$a[5]}\t$division_lon{$a[5]}\t$year\t$month\t$day\t$v\t$vc\n"); # if ($day ne '?');
      }
    } elsif ($a[4] =~ /\w/ && $a[0] =~ /hCoV-19\/$Country\//){
      my @b = split (/-/, $a[2]);
      my $day   = ();
      my $month = ();
      my $year  = ();
      if ($b[0] !~ /\d/){
        $year = '?';
      } else {
        $year = $b[0];
      }
      if ($b[1] !~ /\d/){
        $month = '?';
      } else {
        $month = $b[1];
      }
      if ($b[2] !~ /\d/){
        $day = '?';
      } else {
        $day = $b[2];
      }
      if (1 == 1){
        my $v  = 'other';
        my $vc = '#A5A9A9';
        if ($a[15] eq 'B.1.1.7'){
          $v  = 'Alpha';
          $vc = '#F5F507';
        } elsif ($a[15] eq 'B.1.351'){
          $v  = 'Beta';
          $vc = '#F507F5';
        } elsif ($a[15] eq 'P.1'){
          $v  = 'Gamma';
          $vc = '#07F507';
        } elsif ($a[15] eq 'B.1.617.2'){
          $v  = 'Delta';
          $vc = '#0707F5';
        } elsif ($a[15] eq 'B.1.1.529' || $a[15] eq 'BA.1' ||
                 $a[15] eq 'BA.1.1' || $a[15] eq 'BA.2' ||
                 $a[15] eq 'BA.2'){
          $v  = 'Omicron';
          $vc = '#F50707';
        }
        #print ("$a[0]\t$a[4]\t$country_lat{$a[4]}\t$country_lon{$a[4]}\t$year\t$month\t$day\n");
        print ROB ("$a[0]\t$country_lat{$a[4]}\t$country_lon{$a[4]}\t$year\t$month\t$day\t$v\t$vc\n"); # if ($day ne '?');
      }
    } elsif ($a[3] =~ /\w/ && $a[0] =~ /hCoV-19\/$Country\//){
      my @b = split (/-/, $a[2]);
      my $day   = ();
      my $month = ();
      my $year  = ();
      if ($b[0] !~ /\d/){
        $year = '?';
      } else {
        $year = $b[0];
      }
      if ($b[1] !~ /\d/){
        $month = '?';
      } else {
        $month = $b[1];
      }
      if ($b[2] !~ /\d/){
        $day = '?';
      } else {
        $day = $b[2];
      }
      if (1 == 1){
        my $v  = 'other';
        my $vc = '#A5A9A9';
        if ($a[15] eq 'B.1.1.7'){
          $v  = 'Alpha';
          $vc = '#F5F507';
        } elsif ($a[15] eq 'B.1.351'){
          $v  = 'Beta';
          $vc = '#F507F5';
        } elsif ($a[15] eq 'P.1'){
          $v  = 'Gamma';
          $vc = '#07F507';
        } elsif ($a[15] eq 'B.1.617.2'){
          $v  = 'Delta';
          $vc = '#0707F5';
        } elsif ($a[15] eq 'B.1.1.529' || $a[15] eq 'BA.1' ||
                 $a[15] eq 'BA.1.1' || $a[15] eq 'BA.2' ||
                 $a[15] eq 'BA.2'){
          $v  = 'Omicron';
          $vc = '#F50707';
        }
        #print ("$a[0]\t$a[3]\t$region_lat{$a[5]}\t$region_lon{$a[5]}\t$year\t$month\t$day\n");
        print ROB ("$a[0]\t$region_lat{$a[4]}\t$region_lon{$a[4]}\t$year\t$month\t$day\t$v\t$vc\n");# if ($day ne '?');
      }
    }
  }
}
close (ROB);
close (MIA);
#die ("bien!\n");
