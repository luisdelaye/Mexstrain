#!/usr/bin/perl

# This substitutes the large names of outgroup sequences for smaller names.

# use
# perl substitutename.pl metadata.sampled.tsv
# out: outfile.tsv

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

my $file = $ARGV[0]; # metadata.sampled.tsv

#-----------------------------------------------------------------------------------------
# Review the file
open (MIA, "$file") or die ("Can't open file $file\n");
open (ROB, ">outfile.tsv") or die ("Can't open file outfile.tsv\n");
while (my $linea = <MIA>){
	if ($linea =~ /Wuhan\/WH01\/2019/){
	    print ("bingo!\n");
			print ("hCoV-19/Wuhan/WH01/2019|2019-12-26\2020-01-30 is substituted by Wuhan/WH01/2019\n");
			$linea =~ s/hCoV-19\/Wuhan\/WH01\/2019\|2019-12-26\|2020-01-30/Wuhan\/WH01\/2019/;
    	print ROB ("$linea");
    } elsif ($linea =~ /Wuhan\/Hu-1\/2019/){
    	print ("bingo!\n");
			print ("hCoV-19/Wuhan/Hu-1/2019|2019-12-31|2020-01-12 is substituted by Wuhan/Hu-1/2019\n");
			$linea =~ s/hCoV-19\/Wuhan\/Hu-1\/2019\|2019-12-31\|2020-01-12/Wuhan\/Hu-1\/2019/;
    	print ROB ("$linea");
	} else {
    	print ROB ("$linea");
  }
}
close (ROB);
close (MIA);
#my $pausa = <STDIN>;
#-----------------------------------------------------------------------------------------
