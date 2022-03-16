#!/usr/bin/perl

# This substitutes the large names of outgroup sequences for smaller names.

# use
# perl substitutename.pl metadata.sampled.tsv
# out: outfile
# or
# perl substitutename.pl sequences.sampled.fasta
# out: outfile


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

my $file = $ARGV[0]; # metadata.sampled.tsv or sequences.sampled.fasta

#-------------------------------------------------------------------------------
# Check if an outfile.tsv file already exists

if (-e 'outfile'){
	print ("\n------------------------------------------------------------------------\n");
	print ("A file named outfile already exists.\n");
	print ("If you continue with the analysis, its content will be replaced.\n");
	print ("Do you want to continue? (y/n)\n");
	my $answer = <STDIN>;
	if ($answer =~ /n/i){
		die;
	} else {
		system ("rm outfile\n")
	}
}

#-----------------------------------------------------------------------------------------
# Review the file

my $n1 = 0;
my $n2 = 0;

open (MIA, "$file") or die ("Can't open file $file\n");
open (ROB, ">outfile") or die ("Can't open file outfile\n");
while (my $linea = <MIA>){
	if ($linea =~ /Wuhan\/WH01\/2019/){
			if ($linea =~ s/hCoV-19\/Wuhan\/WH01\/2019\|2019-12-26\|2020-01-30/Wuhan\/WH01\/2019/){
    		print ROB ("$linea");
				print ("\nbingo!\n");
				print ("The sequence:\nhCoV-19/Wuhan/WH01/2019|2019-12-26|2020-01-30\nwas substituted by: Wuhan/WH01/2019\n");
				$n1 = 1;
			} else {
				print ("The name of the outgroup is not exactly:\nhCoV-19/Wuhan/WH01/2019|2019-12-26|2020-01-30\n");
				print ("therefore, the name was not substitued by Wuhan/WH01/2019, please check:\n");
				print ("$linea");
			}
    } elsif ($linea =~ /Wuhan\/Hu-1\/2019/){
			if ($linea =~ s/hCoV-19\/Wuhan\/Hu-1\/2019\|2019-12-31\|2020-01-12/Wuhan\/Hu-1\/2019/){
				print ROB ("$linea");
				print ("\nbingo!\n");
				print ("The sequence:\nhCoV-19/Wuhan/Hu-1/2019|2019-12-31|2020-01-12\nwas substituted by: Wuhan/Hu-1/2019\n");
				$n2 = 1;
    	} else {
				print ("The name of the outgroup is not exactly:\nhCoV-19/Wuhan/Hu-1/2019|2019-12-31|2020-01-12\n");
				print ("therefore, the name was not substitued by Wuhan/Hu-1/2019, please check:\n");
				print ("$linea");
			}

	} else {
    	print ROB ("$linea");
  }
}
close (ROB);
close (MIA);
print ("\n");
print ("------------------------------------------------------------------------\n");
if ($n1 == 1 && $n2 == 1){
	print ("The IDs of both outgroups were changed successfully\n");
} elsif ($n1 == 1 && $n2 == 0){
	print ("The following ID was not found in $file:\n");
	print ("hCoV-19/Wuhan/Hu-1/2019|2019-12-31|2020-01-12\n");
} elsif ($n1 == 0 && $n2 == 1){
	print ("The following ID was not found in $file:\n");
	print ("hCoV-19\/Wuhan\/WH01\/2019\|2019-12-26\|2020-01-30\n");
} else {
	print ("The following IDs were not found in $file:\n");
	print ("hCoV-19/Wuhan/Hu-1/2019|2019-12-31|2020-01-12\n");
	print ("hCoV-19/Wuhan/WH01/2019|2019-12-26|2020-01-30\n");
}
print ("------------------------------------------------------------------------\n");
#my $pausa = <STDIN>;
#-----------------------------------------------------------------------------------------
