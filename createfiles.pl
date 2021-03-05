#!/usr/bin/perl

# This script extracts IDs from a metadata.tsv file 

# use
# perl createfiles.pl ncov_Mex_IDs.txt gisaid_hcov-19_Mex.e1.fasta sequences.fasta metadata.tsv gisaid_hcov-19_Mex.e1.tsv

# out: outfile.fasta, outfile.txt, outfile2.fasta, outfile2.txt

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
my $fileM2 = $ARGV[4]; # archivo de GISAID p.ej. gisaid_hcov-19_Mex.e1.tsv

my %nextstrain;
my %gisaid;
my %global;

#-----------------------------------------------------------------------------------------
# Primero guardo los IDs de las secuencias que estan en el archivo de Nextstrain

print ("-----\n");
my $ns = 0;
print ("Sequences from Mexico in Nextstrain latest global analysis (file: $fileNs)\n");
open (MIA, "$fileNs") or die ("Can't open file $fileNs\n");
while (my $linea = <MIA>){
	chomp ($linea);
	$nextstrain{$linea} = 0;
	$global{$linea} = 0;
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
print ("Sequences from Mexico downloaded from GISAID (file: $fileGS)\n");
open (MIA, "$fileGS") or die ("Can't open file $fileGS\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ />/){
		if ($linea =~ />hCoV-19\/([\/\w\d-]+)\|/){
			$gisaid{$1} = 0;
			$global{$1} = 0;
			print ("$gisaid{$1}\t($1)\n");
			$ng++;
		} else {
			die ("Pattern matching recognition (1) failed: $linea\n");
		}
	}
}
close (MIA);
print ("n: $ng\n");
print ("-----\n");
#my $pausa = <STDIN>;

#-----------------------------------------------------------------------------------------
# Ahora veo cuales secuencias de Nextstrain faltan en GISAID-Mex

my $nN = 0;
print ("Sequences in Nextstrain latest global analysis lacking in the above meixcan GISAID set\n");
my @knextstrain = sort keys (%nextstrain);
for (my $i = 0; $i <= $#knextstrain; $i++){
	if (!exists $gisaid{$knextstrain[$i]}){
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
print ("Sequences from Mexico in GISAID that are lacking in Nextstrain latest global analysis\n");
my @kgisaid = sort keys (%gisaid);
for (my $i = 0; $i <= $#kgisaid; $i++){
	if (!exists $nextstrain{$kgisaid[$i]}){
		print ("$gisaid{$kgisaid[$i]}\t($kgisaid[$i])\n");
		$nf++;
	}
}
print ("n: $nf\n");
print ("-----\n");
#my $pausa = <STDIN>;

#-----------------------------------------------------------------------------------------
# Ahora veo cuales secuencias de GISAID-Mex estan tambien en Nextstrain

my $nI = 0;
print ("Sequences from GISAID also present in Nextstrain latest global analysis\n");
my @kgisaid = sort keys (%gisaid);
for (my $i = 0; $i <= $#kgisaid; $i++){
	if (exists $nextstrain{$kgisaid[$i]}){
		print ("$gisaid{$kgisaid[$i]}\t($kgisaid[$i])\n");
		$nI++;
		$gisaid{$kgisaid[$i]} = 1;
	}
}
print ("n: $nI\n");
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
my %faltan;
print ("Sequences from GISAID not yet included in Nextstrain and not present in Nextstrain latest global analysis\n");
for (my $i = 0; $i <= $#kgisaid; $i++){
	if ($gisaid{$kgisaid[$i]} == 0){
		print ("($kgisaid[$i])\t$gisaid{$kgisaid[$i]}\n");
		$faltan{$kgisaid[$i]} = 0;
		$nF++;
	}
}
print ("n: $nF\n");
print ("-----\n");
#my $pausa = <STDIN>;

# Ahora descargo esas secuencias de GISAID-Mex que faltan en Nextstrain

$r = 0;
$sec = ();
$name = ();
my $m2 = 0;
my %meta2;
my %sizes;

open (MIA, "$fileGS") or die ("Can't open file $fileGS\n");
open (ROB, ">outfile2.fasta") or die ("Can't open file outfile2.fasta\n");
while (my $linea = <MIA>){
	chomp ($linea);
	if ($linea =~ />/ && $r == 1){
		if ($name =~ />hCoV-19\/(.+)\|(.+)\|(.+)/){
			#print ("probando: ($1)\n");
			#my $pausa = <STDIN>;
			my $nombre = $1;
			if (exists $faltan{$nombre} && $faltan{$nombre} == 0){
				print ROB (">$nombre\n");
				print ROB ("$sec\n");
				$gisaid{$nombre} = 1;
				$meta2{$nombre} = 0;
				$sizes{$nombre} = length($sec);
				$m2++;
			}
		} else {
			die ("Pattern matching recognition (3) failed: ($name)\n");
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
	if ($name =~ />hCoV-19\/(.+)\|(.+)\|(.+)/){
		my $nombre = $1;
		if (exists $faltan{$nombre} && $faltan{$nombre} == 0){
			print ROB (">$nombre\n");
			print ROB ("$sec\n");
			$gisaid{$nombre} = 1;
			$meta2{$nombre} = 0;
			$sizes{$nombre} = length($sec);
			$m2++;
		}
	} else {
		die ("Pattern matching recognition (3) failed: ($name)\n");
	}
	$r = 0;
	$name = $sec = ();
}
close (ROB);
close (MIA);

# Ahora extraigo los metadatos

my $l = 0;
open (MIA, "$fileM2") or die ("Can't open file $fileM2\n");
open (ROB, ">outfile2.txt") or die ("Can't open file outfile2.txt\n");
# La siguiente linea es solo por control:
# print("strain\tvirus\tgisaid_epi_isl\tgenbank_accession\tdate\tregion\tcountry\tdivision\tlocation\tregion_exposure\tcountry_exposure\tdivision_exposure\tsegment\tlength\thost\tage\tsex\tNextstrain_clade\tpangolin_lineage\tGISAID_clade\toriginating_lab\tsubmitting_lab\tauthors\turl\ttitle\tpaper_url\tdate_submitted\tpurpose_of_sequencing\n");
while (my $linea = <MIA>){
	chomp ($linea);
	my @a = split (/\t/, $linea);
	$l++;
	if ($l == 1){
		# print ROB ("$linea\n");
	} else {
		$a[0] =~ s/hCoV-19\///;
		if (exists $meta2{$a[0]}){
			# print ROB ("$linea\n");
			my @r = split (/ \/ /, $a[3]);
			print ("check regions and size: ($r[0])\t($r[1])\t($r[2])\t($sizes{$a[0]})\n");
			print ROB ("$a[0]\tncov\t$a[1]\t?\t$a[2]\t$r[0]\t$r[1]\t$r[2]\t\t\t\t\tgenome\t$sizes{$a[0]}\t$a[4]\t$a[7]\t$a[6]\t?\t$a[12]\t$a[13]\t?\t?\t?\t?\t?\t?\t$a[2]\t?\n");
			$meta2{$a[0]} = 1;
		} else {
			#print ("Warning, the sequence ($a[0]) does not exist in $fileM2\n");
		}
	}
}
close (ROB);
close (MIA);
my @keys = sort keys (%meta2);
for (my $i = 0; $i <= $#keys; $i++){
	if ($meta2{$keys[$i]} == 0){
		print ("there is no metadata for the sequence: $keys[$i]\t($meta2{$keys[$i]})\n");
	}
}
print ("-----\n");

#-----------------------------------------------------------------------------------------
# Ahora hago un reporte

print ("Sequences from Mexico in Nextstrain latest global analysis (LGA) .................................................: $ns\n");
print ("Sequences from Mexico in GISAID (including those with and without Nextstrain format) .............................: $ng\n");
print ("Sequences shared between the above sets ..........................................................................: $nI\n");
print ("Sequences from Mexico in Nextstrain LGA that are absent from the mexican GISAID set ..............................: $nN\n");
print ("Sequences from Mexico in GISAID that are absent in Nextstrain LGA ................................................: $nf\n");
my $tot = $nI + $nN + $nf;
print ("Total sequences from Mexico ......................................................................................: $tot\n");
print ("-----\n");
print ("Sequences from Mexico in GISAID that are absent in Nextstrain LGA and were already formated for Nextstrain .......: $m\n");
print ("Sequences from Mexico in GISAID that are absent in Nextstrain LGA that do not have the format for Nextstrain yet .: $nF:$m2\n");
if ($nf == ($m+$nF)){
	print ("$nf = ($m + $nF), looks Ok!\n");
} else {
	print ("$nf != ($m + $nF), warning!\n");
}
if ($nF == $m2){
	print ("$nF = $m2, looks Ok!\n");
} else {
	print ("$nF != $m2, warning!\n");
}
print ("-----\n");
print ("Now please cat the following files (example):\n");
print ("\$ cat nextstrain_ncov_global_metadata.f.tsv outfile.txt outfile2.txt > nextstrain_ncov_global_metadata.fc.tsv\n");
print ("\$ cat nextstrain_ncov_global_metadata.fasta outfile.fasta outfile2.fasta > nextstrain_ncov_global_metadata.fc.fasta\n");
print ("-----\n");
