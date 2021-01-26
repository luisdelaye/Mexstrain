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
print ("Sequences from Mexico in Nextstrain latest analysis (file: $fileNs)\n");
print ("note: not all these sequences will be in the GISAID set\n");
open (MIA, "$fileNs") or die ("Can't open file $fileNs\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$nextstrain{$linea} = 0;
	print ("$nextstrain{$linea}\t($linea)\n");
	$ns++;
}
close (MIA);
print ("n: $ns\n");
print ("-----\n");
#my $pausa = <STDIN>;

#-----------------------------------------------------------------------------------------
# Luego guardo los IDs de las secuencias del archivo de GISAID-Mex

my $ng = 0;
my $ng_0 = 0;
my $ng_1 = 0;
#print ("Secuencias de Mexico en GISAID\n");
#print ("(no todas estas secuencias han sido procesadas para Nextstrain necesariamente)\n");
print ("Sequences from Mexico in GISAID (file: $fileGS)\n");
print ("note: not all these sequences will be in the Nextstrain set\n");
open (MIA, "$fileGS") or die ("Can't open file $fileGS\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ />/){
		if ($linea =~ />hCoV-19\/([\/\w\d-]+)\|/){
			$gisaid{$1} = 0;
			if (exists $nextstrain{$1}){
				$gisaid{$1} = 1;
				$nextstrain{$1} = 1;
			}
			print ("$gisaid{$1}\t($1)\n");
			$ng++;
			if ($gisaid{$1} == 0){
				$ng_0++;
			} else {
				$ng_1++;
			}
		} else {
			die ("Pattern matching recognition (1) failed: $linea\n");
		}
	}
}
close (MIA);
print ("n: $ng\n");
print ("0: $ng_0 sequences found only in GISAID\n");
print ("1: $ng_1 sequences found in GISAID and Nextstrain\n");
print ("-----\n");
#my $pausa = <STDIN>;

#-----------------------------------------------------------------------------------------
# Ahora veo cuales secuencias de Nextstrain faltan en GISAID-Mex

my $nN = 0;
print ("Sequences in Nextstrain latest analysis lacking in GISAID\n");
my @knextstrain = sort keys (%nextstrain);
for (my $i = 0; $i <= $#knextstrain; $i++){
	if ($nextstrain{$knextstrain[$i]} == 0){
		print ("$nextstrain{$knextstrain[$i]}\t($knextstrain[$i])\n");
		$nN++;
	}
}
print ("n: $nN\n");
print ("-----\n");
#my $pausa = <STDIN>;

#-----------------------------------------------------------------------------------------
# Ahora veo cuales secuencias de GISAID-Mex faltan en Nextstrain

my $nf = 0;
#print ("Secuencias de Mexico en GISAID que no estan en el analisis de filodinamica de Nextstrain\n");
#print ("(son las que tengo que buscar en el archivo $fileSe)\n");
print ("Sequences from GISAID lacking in Nextstrain latest analysis\n");
my @kgisaid = sort keys (%gisaid);
for (my $i = 0; $i <= $#kgisaid; $i++){
	if ($gisaid{$kgisaid[$i]} == 0){
		print ("$gisaid{$kgisaid[$i]}\t($kgisaid[$i])\n");
		$nf++;
	}
}
print ("n: $nf\n");
print ("note: these sequences will be extracted from $fileSe and added to outfile.fasta\n");
print ("-----\n");
#my $pausa = <STDIN>;

#-----------------------------------------------------------------------------------------
# Ahora extraigo de sequences.fasta, las secuencias de GISAID que no estan en Nextstrain

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
# Ahora veo cuales secuencias de GISAID-Mex me siguen faltando en Nextstrain

my $nF = 0;
#print ("Secuencias de Mexico en GISAID que aun no han sido procesadas para Nextstrain\n");
#print ("(tendria que descargarlas manualmente de GISAID junto con sus metadatos)\n");
print ("Sequences from GISAID not yet included in Nextstrain\n");
print ("note: these sequences (if anay) and their metadata have to be downloaded from GISAID and included manually in outfile.fasta and outfile.txt\n");
for (my $i = 0; $i <= $#kgisaid; $i++){
	if ($gisaid{$kgisaid[$i]} == 0){
		print ("$kgisaid[$i]\t$gisaid{$kgisaid[$i]}\n");
		$nF++;
	}
}
print ("n: $nF\n");
print ("-----\n");
#my $pausa = <STDIN>;

#-----------------------------------------------------------------------------------------
# Ahora hago un reporte

#print ("numero de secuencias mexicanas en nextstrain .......................................: $ns\n");
#print ("numero de secuencias mexicanas en GISAID (sin procesar) ............................: $ng\n");
#print ("numero de secuencias que estan en GISAID (sin procesar) y que faltan en nextstrain .: $nf\n");
#print ("numero de secuencias faltantes en nextstrain que encontro en GISAID (procesado) ....: $m\n");
#print ("numero de secuencias faltantes en nextstrain que no encontro en GISAID (procesado) .: $nF\n");
#print ("\nNota: es necesario esperar a que Nextstrain procese las $nF secuencias de GISAID\n");

print ("Sequences from Mexico in Nextstrain .......................................: $ns\n");
print ("Sequences from Mexico in GISAID ...........................................: $ng\n");
print ("Sequences from Mexico in GISAID that are absent in Nextstrain .............: $nf\n");
print ("Sequences from Mexico in GISAID that are absent in Nextstrain, recovered ..: $m\n");
print ("Sequences from Mexico in Nextstrain absent from GISAID ....................: $nN\n");
print ("Sequences from Mexico in GISAID that continue to be absent from Nextstrain : $nF\n");
print ("-----\n");
print ("Now please cat the following files (example):\n");
print ("\$ cat nextstrain_ncov_global_metadata.f.tsv outfile.txt > nextstrain_ncov_global_metadata.fc.tsv\n");
print ("\$ cat nextstrain_ncov_global_metadata.fasta outfile.fasta > nextstrain_ncov_global_metadata.fc.fasta\n");
print ("-----\n");
