#!/usr/bin/perl

# This script extracts IDs from a metadata.tsv file 

# use
# perl extractids.pl nextstrain_ncov_global_metadata.f.tsv 17 Mexico

# out: outfile

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

my $file = $ARGV[0];
my $col  = $ARGV[1];
my $cou  = $ARGV[2];

my %hash;

my $l = 0;
my $n = 0;

open (MIA, "$file") or die ("Can't open file $file\n");
open (ROB, ">outfile") or die ("Can't open file outfile\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$l++;
	my @a = split (/\t/, $linea);
	if ($l > 1){
		if ($a[6] =~ /$cou/){
			$hash{$a[$col]} += 1;
			print ("$a[0]\t$a[7]\t$a[$col]\n");
			print ROB ("$a[0]\n");
		#	print ("$linea\n");
			$n++;
		}
		#my $pausa = <STDIN>;
	} else {
		for (my $i = 0; $i <= $#a; $i++){
			#print ("$i\t$a[$i]\n");
		}
	}
}
close (ROB);
close (MIA);
print ("\nn: $n\n");

my @keys = ordena(\%hash);

for (my $i = 0; $i <= $#keys; $i++){
	print ("$keys[$i]\t$hash{$keys[$i]}\n");
}

sub ordena {

	# Recibe una referencia a un hash
	my $hashref = $_[0];
	my @ordenados = ();

	my @a = keys (%{$hashref});
	my $N_de_elementos = $#a +1;

	my $suma = 0;
	until ($suma == $N_de_elementos){
		for (my $i = 0; $i <= $#a; $i++){
			#print ("\nOrdenando: $a[$i] ($hash{$a[$i]})\n");
			my $elmayor = 'si';
			for (my $j = 0; $j <= $#a; $j++){
				if ($i != $j){
					#print ("\t$a[$j] ($hash{$a[$j]})\n");
					if ($hashref->{$a[$i]} < $hashref->{$a[$j]}){
						$elmayor = 'no';
					}
				}
			}
			#print ("es el mayor: $elmayor\n");
			if ($elmayor eq 'si'){
				push (@ordenados, $a[$i]);
				my $salta = $i;
				my $ordenado = splice (@a, $salta, 1);
				#print ("\nordenado: $ordenado\n");
				$suma++;
			}
			#$pausa = <STDIN>;
		}

	}
	
	return (@ordenados);
}
