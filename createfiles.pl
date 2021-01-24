#!/usr/bin/perl

# This script extracts IDs from a metadata.tsv file 

# use
# perl createfiles.pl ncov_Mex_IDs.txt gisaid_hcov-19_Mex.e1.fasta sequences.fasta metadata.tsv 

# out: outfile.fasta, outfile.txt

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

my $fileNs = $ARGV[0]; # archivo de Nextstrain, p.ej. ncov_Mex_IDs.txt
my $fileGS = $ARGV[1]; # archivo de GISAID p.ej. gisaid_hcov-19_2020_11_16_01_Mex.e1.fasta
my $fileSe = $ARGV[2]; # archivo de GISAID p.ej. sequences.fasta
my $fileMe = $ARGV[3]; # archivo de GISAID p.ej. metadata.tsv

my %nextstrain;
my %gisaid;

#-----------------------------------------------------------------------------------------
# Primero guardo los IDs de las secuencias que estan en el archivo de Nextstrain

my $ns = 0;
#print ("Secuencias que estan en el analisis de filodinamica de Nextstrain\n");
print ("Sequences in Nextstrain\n");
print ("file: $fileNs\n");
open (MIA, "$fileNs") or die ("Can't open file $fileNs\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$nextstrain{$linea} = 0;
	print ("$nextstrain{$linea}\t($linea)\n");
	$ns++;
}
close (MIA);
print ("-----\n");

#-----------------------------------------------------------------------------------------
# Luego guardo los IDs de las secuencias del archivo de GISAID-Mex

my $ng = 0;
#print ("Secuencias de GISAID (sin procesar) que son de Mexico\n");
#print ("(no todas estas secuencias han sido procesadas para Nextstrain necesariamente)\n");
print ("Sequences from GISAID (unprocessed)\n");
print ("file: $fileGS\n");
open (MIA, "$fileGS") or die ("Can't open file $fileGS\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ />/){
		if ($linea =~ />hCoV-19\/([\/\w\d-]+)\|/){
			$gisaid{$1} = 0;
			if (exists $nextstrain{$1}){
				$gisaid{$1} = 1;
			}
			print ("$gisaid{$1}\t($1)\n");
			$ng++;
		} else {
			die ("Pattern matching recognition (1) failed: $linea\n");
		}
	}
}
close (MIA);
print ("-----\n");

#-----------------------------------------------------------------------------------------
# Ahora veo cuales secuencias de GISAID-Mex faltan en Nextstrain

my $nf = 0;
#print ("Secuencias mexicanas de GISAID (sin procesar) que no estan en el analisis de filodinamica de Nextstrain\n");
#print ("(son las que tengo que buscar en el archivo $fileSe)\n");
print ("Sequences from GISAID (unprocessed) lacking in Nextstrain\n");
my @kgisaid = sort keys (%gisaid);
for (my $i = 0; $i <= $#kgisaid; $i++){
	if ($gisaid{$kgisaid[$i]} == 0){
		print ("$gisaid{$kgisaid[$i]}\t($kgisaid[$i])\n");
		$nf++;
	}
}
print ("-----\n");

#-----------------------------------------------------------------------------------------
# Ahora extraigo las secuencias que faltan de sequences.fasta

my $r = 0;
my $sec;
my $name;
my $m = 0;
my %meta;

open (MIA, "$fileSe") or die ("Can't open file $fileSe\n");
open (ROB, ">outfile.fasta") or die ("Can't open file outfile.fasta\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ />/ && $r == 1){
		if ($name =~ />(.+)/){
			my $nombre = $1;
			if (exists $gisaid{$nombre} && $gisaid{$nombre} == 0){
				print ROB ("$name\n");
				print ROB ("$sec\n");
				$gisaid{$nombre} = 1;
				$meta{$nombre} = 0;
				$m++;
			}
		} else {
			die ("Pattern matching recognition (2) failed: ($name)\n");
		}
		$r = 0;
		$name = $sec = ();
	}
	if ($linea !~ />/ && $r == 1){
		$sec = $sec.$linea;
	}
	if ($linea =~ />/ && $r == 0){
		$name = $linea;
		$r = 1;
	}
}
if ($r == 1){
	if ($name =~ />(.+)/){
		my $nombre = $1;
		if (exists $gisaid{$nombre} && $gisaid{$nombre} == 0){
			print ROB ("$name\n");
			print ROB ("$sec\n");
			$gisaid{$nombre} = 1;
			$meta{$nombre} = 0;
			$m++;
		}
	} else {
		die ("Pattern matching recognition (2) failed: ($name)\n");
	}
	$r = 0;
	$name = $sec = ();
}
close (ROB);
close (MIA);

#-----------------------------------------------------------------------------------------
# Ahora veo cuales secuencias de GISAID-Mex me siguen faltando en Nextstrain

my $nF = 0;
#print ("Secuencias mexicanas de GISAID (sin procesar) que aun no han sido procesadas para Nextstrain\n");
#print ("(tendria que descargarlas manualmente de GISAID junto con sus metadatos)\n");
print ("Sequences from GISAID (unprocessed)\n");
for (my $i = 0; $i <= $#kgisaid; $i++){
	if ($gisaid{$kgisaid[$i]} == 0){
		print ("$kgisaid[$i]\t$gisaid{$kgisaid[$i]}\n");
		$nF++;
	}
}
print ("-----\n");

#-----------------------------------------------------------------------------------------
# Ahora extraigo los metadatos

my $l = 0;
open (MIA, "$fileMe") or die ("Can't open file $fileMe\n");
open (ROB, ">outfile.txt") or die ("Can't open file outfile.txt\n");
while (my $linea = <MIA>){
	chomp ($linea);
	my @a = split (/\t/, $linea);
	$l++;
	if ($l == 1){
		# print ROB ("$linea\n");
	} else {
		if (exists $meta{$a[0]}){
			print ROB ("$linea\n");
			$meta{$a[0]} = 1;
		}
	}
}
close (ROB);
close (MIA);
my @keys = sort keys (%meta);
for (my $i = 0; $i <= $#keys; $i++){
	if ($meta{$keys[$i]} == 0){
		print ("there is no metadata for the sequence: $keys[$i]\t($meta{$keys[$i]})\n");
	}
}

#-----------------------------------------------------------------------------------------
# Ahora hago un reporte

#print ("numero de secuencias mexicanas en nextstrain.......................................: $ns\n");
#print ("numero de secuencias mexicanas en GISAID (sin procesar)............................: $ng\n");
#print ("numero de secuencias que estan en GISAID (sin procesar) y que faltan en nextstrain.: $nf\n");
#print ("numero de secuencias faltantes en nextstrain que encontro en GISAID (procesado)....: $m\n");
#print ("numero de secuencias faltantes en nextstrain que no encontro en GISAID (procesado).: $nF\n");
#print ("\nNota: es necesario esperar a que Nextstrain procese las $nF secuencias de GISAID.\n");

print ("Selected sequences in Nextstrain.........................................: $ns\n");
print ("Selected sequences in GISAID (unprocessed)...............................: $ng\n");
print ("Selected sequences in GISAID (unprocessed) lacking in Nextstrain.........: $nf\n");
print ("Lacking selected sequences in Nextstrain found in GISAID (processed).....: $m\n");
print ("Lacking selected sequences in Nextstrain not found in GISAID (processed).: $nF\n");

print ("-----\n");



