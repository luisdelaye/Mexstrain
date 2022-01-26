#!/usr/bin/perl

# This script create a metadata table in the format required for Nextstrain.

# use
# perl format_metadata.pl metadata.e1.tsv sequences.fasta.headers.txt spikeprot####.fasta.headers.txt
# out:
# outfile.tsv

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

my $fileMe = $ARGV[0]; # metadata.e1.tsv file
my $fileSe = $ARGV[1]; # sequences.fasta.headers.txt file
my $fileSk = $ARGV[2]; # spikeprot####.fasta.headers.txt file

my %hashSkO;  # information in spikeprot####.fasta, originating lab
my %hashSkS;  # information in spikeprot####.fasta, submitting lab
my %hashSks;  # information in spikeprot####.fasta, submitter

# Other variables used for proccesing data
my %allheaders;

#my @header;

my $l = 0;
my $n = 0;
my $m = 0;

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
# Process sequences.headers.fasta file

open (MIA, "$fileSe") or die ("Can't open $fileSe\n");
while (my $linea = <MIA>){
	chomp ($linea);
  if ($linea =~ />(.+)/){
    my $id = $1;
		$allheaders{$id} = 1;
  }
}
close (MIA);

#-------------------------------------------------------------------------------
# Gather information from the spikeprot####.fasta file
open (MIA, "$fileSk") or die ("Can't open $fileSk\n");
while (my $linea = <MIA>){
	chomp ($linea);
  if ($linea =~ />/){
    my @a = split (/\|/, $linea);
      $hashSkO{$a[3]} = $a[7];
      $hashSkS{$a[3]} = $a[8];
      $hashSks{$a[3]} = $a[9];
  }
}
#close (MIA);
#die ("bien!\n");
#-------------------------------------------------------------------------------
# Gather information from the metadata.e1.tsv file and create outfile.tsv
$n = 0;
open (MIA, "$fileMe") or die ("Can't open $fileMe\n");
open (ROB, ">outfile.tsv") or die ("Can't open outfile.tsv\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
  if ($l > 1){
    #print ("-----\n");
    my @a = split (/\t/, $linea);
    $a[0] =~ s/hCoV-19\///;
    my @b = split (/\//, $a[4]);
		my $Region = ();
    my $Country = ();
    my $Division = ();
    my $Location = ();
    for (my $i = 0; $i <= $#b; $i++){
      if ($i == 0){
        $Region = $b[$i];
				$Region =~ s/^\s+//;
				$Region =~ s/\s+$//;
      } elsif ($i == 1){
        $Country = $b[$i];
				$Country =~ s/^\s+//;
				$Country =~ s/\s+$//;
      } elsif ($i == 2){
        $Division = $b[$i];
				$Division =~ s/^\s+//;
				$Division =~ s/\s+$//;
      } elsif ($i == 3){
        $Location = $b[$i];
				$Location =~ s/^\s+//;
				$Location =~ s/\s+$//;
      }
    }
    # Create metadata.e2.tsv $file
    my $id = 'hCoV-19/'.$a[0].'|'.$a[3].'|'.$a[15];
    $allheaders{$id} += 1;
		my $submitter = $hashSks{$a[2]};
		if ($submitter !~ /[A-Za-z]/){
			$submitter = '?';
		}
		if (exists $allheaders{$id}){
    	print ROB ("$id\t$a[2]\t$a[3]\t$Region\t$Country\t$Division\t$Location\t$Region\t$Country\t$Division\t$a[6]\t$a[7]\t$a[8]\t$a[9]\t$a[10]\t$a[11]\t$a[12]\t$hashSkO{$a[2]}\t$hashSkS{$a[2]}\t$submitter\t$a[15]\n");
			$n++;
    } else {
			$allheaders{$id} = 0;
			$m++;
		}
  } else {
    print ROB ("strain\tgisaid_epi_isl\tdate\tregion\tcountry\tdivision\tlocation\tregion_exposure\tcountry_exposure\tdivision_exposure\tlength\thost\tage\tsex\tclade\tpango_lineage\tpango_version\toriginating_lab\tsubmitting_lab\tsubmitter\tdate_submitted\n");
  }
}
close (ROB);
close (MIA);
#die ("bien!\n");
#-------------------------------------------------------------------------------
# Count if there are lacking headers

if ($m > 0){
	print ("------------------------------------------------------------------------\n");
	print ("The following headers were not found in sequences.fasta, we recommend\n");
	print ("to delete the respective row(s) from outfile.tsv\n");
	my @kallheaders = sort keys (%allheaders);
	for (my $i = 0; $i <= $#kallheaders; $i++){
  	if ($allheaders{$kallheaders[$i]} == 0){
    	print ("\n($kallheaders[$i])\tWarning! this header is not found in $fileMe\n");
  	}
	}
	print ("\n");
	print ("------------------------------------------------------------------------\n");
	print ("Number of fasta headers found in $fileSe....: $n\n") if ($m > 0);
	print ("Number of fasta headers not found in $fileSe: $m\n") if ($m > 0);
	print ("------------------------------------------------------------------------\n");
} else {
	print ("------------------------------------------------------------------------\n");
	print ("Number of headers in outfile.tsv: $n\n");
	print ("------------------------------------------------------------------------\n");
}
#-------------------------------------------------------------------------------
