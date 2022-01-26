#!/usr/bin/perl

# This script substitutes hiden characters ^M by \n

# use
# perl script-0-replace_Mc.pl file
# out: file.e1

# Autor
# Luis Jose Delaye Arredondo
# Laboratorio de Genomica Evolutiva
# Departamento de Ingenieria Genetica
# CINVESTAV - Irapuato
# Mexico
# ldelaye@ira.cinvestav.mx
# Copy-Left  = : - )

# beta.1.2 version

$file = $ARGV[0];
chomp ($file);

$out = $file.'.e1';

$cuantoshay = $cuantossustituyo = $cuantoshaySINC = 0;
open (MIO, "$file") || die ("No puedo abrir $file\n");
open (MIA, ">sinM.txt") || die ("No puedo abrir sinM.txt\n");

while ($linea = <MIO>){
	if ($linea =~//){
		if ($linea =~//){
			$linea =~ s//\n/g;
			print MIA ("$linea");
			$cuantossustituyo++;
		}
		$cuantoshay++;
	} else {
		print MIA ("$linea");
		$cuantoshaySINC++;
	}
	$lineas++;
}

close (MIA);
close (MIO);

print (" Number of ^M: $cuantoshay\n Number of replaced ^M: $cuantossustituyo\n Number of lines without ^M: $cuantoshaySINC\n");
#print ("Analizo $lineas lineas\n");

open (MIA, "sinM.txt") or die ("no puedo abrir sinM.txt\n");
open (ROB, ">$out") or die ("no puedo abrir $out\n");
while (my $linea = <MIA>){
	if ($linea =~ /.+/){
		print ROB ("$linea");
	}
}
close (ROB);
close (MIA);
print (" outfile: $out\n");
system ("rm sinM.txt");
