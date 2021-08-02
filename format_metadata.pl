#!/usr/bin/perl

# This script create a metadata table in the format required for Nextstrain

# use
# perl format_metadata.pl metadata.e1.tsv sequences.fasta.headers.txt spikeprot0511.fasta.headers.txt color_ordering.e1.tsv
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

my $fileMe = $ARGV[0]; # metadata.tsv file
my $fileSe = $ARGV[1]; # sequences.fasta file
my $fileSk = $ARGV[2]; # spikeprot####.fasta file
my $fileCo = $ARGV[3]; # color_ordering.tsv file

my %hashMe;   # information in metadata.tsv
my %region;   # information in metadata.tsv
my %country;  # information in metadata.tsv
my %division; # information in metadata.tsv
my %location; # information in metadata.tsv
my %hashSe;   # information in sequences.fasta
my %hashSkO;  # information in spikeprot####.fasta, originating lab
my %hashSkS;  # information in spikeprot####.fasta, submitting lab
my %hashSks;  # information in spikeprot####.fasta, submitter
my %hashCo;   # information in color_ordering.tsv
my %hashCoO;  # information in color_ordering.tsv

# Other variables used for proccesing data
my %country_ne;
my %region_ne;
my %division_ne;
my %location_ne;
my %allheaders;

my @header;

my $l = 0;
my $n = 0;
my $m = 0;

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
# Gather information from the color_ordering.tsv file
open (MIA, "$fileCo") or die ("Can't open $fileCo\n");
while (my $linea = <MIA>){
	chomp ($linea);
  if ($linea !~ /#/ && $linea =~ /\w/){
    my @a = split (/\t/, $linea);
    my $original = $a[1];
    $a[1] =~ tr/A-Z/a-z/;
    $hashCo{$a[1]} = $a[0] if ($a[0] ne 'recency');
    $hashCoO{$a[1]} = $original if ($a[0] ne 'recency');
  }
}
close (MIA);
my @geo = sort keys (%hashCo);
#die ("bien!\n");
#-------------------------------------------------------------------------------
# Gather information from the metadata.tsv file and create outfile.tsv
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
    for (my $i = 0; $i <= $#b; $i++){
      $b[$i] =~ s/^\s+//;
      $b[$i] =~ s/\s+$//;
      $b[$i] =~ tr/A-Z/a-z/;
      if ($hashCo{$b[$i]} eq 'region'){
        $region{$a[2]} = $b[$i];
      } elsif ($hashCo{$b[$i]} eq 'country'){
        $country{$a[2]} = $b[$i];
      } elsif ($hashCo{$b[$i]} eq 'division'){
        $division{$a[2]} = $b[$i];
      } elsif ($hashCo{$b[$i]} eq 'location'){
        $location{$a[2]} = $b[$i];
      }
    }
    # Capitalize
    my $Region = capitalize($region{$a[2]});
    my $Country = capitalize($country{$a[2]});
    my $Division = capitalize($division{$a[2]});
    my $Location = capitalize($location{$a[2]});
    # Check that names are handled correctly
    if ($hashCoO{$country{$a[2]}} ne $Country){
      $country_ne{$hashCoO{$country{$a[2]}}} = $Country;
    }
    if ($hashCoO{$region{$a[2]}} ne $Region){
      $region_ne{$hashCoO{$region{$a[2]}}} = $Region;
    }
    if ($hashCoO{$division{$a[2]}} ne $Division){
      $division_ne{$hashCoO{$division{$a[2]}}} = $Division;
    }
    if ($hashCoO{$location{$a[2]}} ne $Location){
      $location_ne{$hashCoO{$location{$a[2]}}} = $Location;
    }
    # Create metadata.e2.tsv $file
    my $id = 'hCoV-19/'.$a[0].'|'.$a[3].'|'.$a[15];
    $allheaders{$id} += 1;
		my $submitter = $hashSks{$a[2]};
		if ($submitter !~ /[A-Za-z]/){
			$submitter = '?';
		}
    print ROB ("$id\t$a[2]\t$a[3]\t$Region\t$Country\t$Division\t$Location\t$a[6]\t$a[7]\t$a[8]\t$a[9]\t$a[10]\t$a[11]\t$a[12]\t$hashSkO{$a[2]}\t$hashSkS{$a[2]}\t$submitter\n");
    #for (my $i = 0; $i <= $#a; $i++){
      #print ("$header[$i]:\t$a[$i]\n");
      # strain hCoV-19/$a[0]|$a[3]|$a[15]
      ##print ("strain:\thCoV-19/$a[0]|$a[3]|$a[15]\n");
      # virus ncov
      # gisaid_epi_isl $a[2]
      ##print ("gisaid_epi_isl:\t$a[2]\n");
      # genbank_accession ?
      # date $a[3]
      ##print ("date:\t$a[3]\n");
      # region $Region
      ##print ("region:\t$Region\n");
      # country $Country
      ##print ("country:\t$Country\n");
      # division $Division
      ##print ("division:\t$Division\n");
      # location $Location
      ##print ("location:\t$Location\n");
      # region_exposur
      # country_exposure
      # division_exposure
      # segment genome
      # length $a[6]
      ##print ("length:\t$a[6]\n");
      # host $a[7]
      ##print ("host:\t$a[7]\n");
      # age $a[8]
      ##print ("age:\t$a[8]\n");
      # sex $a[9]
      ##print ("sex:\t$a[9]\n");
      # clade $a[10]
      ##print ("clade:\t$a[10]\n");
      # pango_lineage $a[11]
      ##print ("pango_lineage:\t$a[11]\n");
      # pangolin_version $a[12]
      ##print ("pango_version:\t$a[12]\n");
      # originating_lab
      ##print ("originating_lab:\t$hashSkO{$a[2]}\n");
      # submitting_lab
      ##print ("submitting_lab:\t$hashSkS{$a[2]}\n");
      # submitter
      ##print ("submitter:\t$hashSks{$a[2]}\n");
    #}
    #my $pausa = <STDIN>;
  } else {
    @header = split (/\t/, $linea);
    print ROB ("strain\tgisaid_epi_isl\tdate\tregion\tcountry\tdivision\tlocation\tlength\thost\tage\tsex\tclade\tpango_lineage\tpango_version\toriginating_lab\tsubmitting_lab\tsubmitter\n");
  }
}
close (ROB);
close (MIA);
#print ("$n\n");
#print ("\nScale\tOriginal\tNew\n");
#open (ROB, ">code.txt") or die ("Can't open code.txt\n");
my @kRne = sort keys (%region_ne);
print ("\nWarning! misspelled names:\n") if (@kRne > 0);
print ("Category\t(original name)\t(misspelled name)\n") if (@kRne > 0);
foreach my $rne (@kRne){
  print ("Region\t($rne)\t($region_ne{$rne})\n");
  # Use this code to print elsif instructions to identify regions
  # that need to be specified in the 'capitalize' subrutine
  #print ROB ("  } elsif (\$newword eq '$region_ne{$rne}'){\n");
  #print ROB ("   \$newword = '$rne';\n");
}
my @kCne = sort keys (%country_ne);
print ("\nWarning! misspelled names:\n") if (@kCne > 0);
print ("Category\t(original name)\t(misspelled name)\n") if (@kCne > 0);
foreach my $cne (@kCne){
  print ("Country\t($cne)\t($country_ne{$cne})\n");
  # Use this code to print elsif instructions to identify countries
  # that need to be specified in the 'capitalize' subrutine
  #print ROB ("  } elsif (\$newword eq '$country_ne{$cne}'){\n");
  #print ROB ("   \$newword = '$cne';\n");
}
my @kDne = sort keys (%division_ne);
print ("\nWarning! misspelled names:\n") if (@kDne > 0);
print ("Category\t(original name)\t(misspelled name)\n") if (@kDne > 0);
foreach my $dne (@kDne){
  print ("Division\t($dne)\t($division_ne{$dne})\n");
  # Use this code to print elsif instructions to identify divisions
  # that need to be specified in the 'capitalize' subrutine
  #print ROB ("  } elsif (\$newword eq '$division_ne{$dne}'){\n");
  #print ROB ("   \$newword = '$dne';\n");
}
my @kLne = sort keys (%location_ne);
print ("\nWarning! misspelled names:\n") if (@kLne > 0);
print ("Category\t(original name)\t(misspelled name)\n") if (@kLne > 0);
foreach my $lne (@kLne){
  print ("Location\t($lne)\t($location_ne{$lne})\n");
  # Use this code to print elsif instructions to identify locations
  # that need to be specified in the 'capitalize' subrutine
  #print ROB ("  } elsif (\$newword eq '$location_ne{$lne}'){\n");
  #print ROB ("   \$newword = '$lne';\n");
}
#close (ROB);
if (@kLne > 0 || @kDne > 0 || @kCne > 0 || @kRne > 0){
	print ("\nThere are misspelled names\n");
	print ("You have to open format_metadata.pl and code Perl to fix the problem\n");
	print ("Go to the bottom of the file and where indicated, code:\n");
	print ("\n");
	print ("  } elsif (\$newword =~ /misspelled name/){\n");
    print ("    \$newword = 'original name';\n");
    print ("\nYou may need to use pattern matching to contend with unusual characters\n");
	print ("Press enter to continue\n");
	my $pausa = <STDIN>;
}
#die ("bien!\n");
#-------------------------------------------------------------------------------
# Process sequences.headers.fasta file
$n = 0;
open (MIA, "$fileSe") or die ("Can't open $fileSe\n");
while (my $linea = <MIA>){
	chomp ($linea);
  if ($linea =~ />(.+)/){
    my $id = $1;
    if (!exists $allheaders{$id}){
        $allheaders{$id} = 0;
        $m++;
      } else {
        $n++;
      }
  }
}
close (MIA);
my @kallheaders = sort keys (%allheaders);
for (my $i = 0; $i <= $#kallheaders; $i++){
  if ($allheaders{$kallheaders[$i]} == 0){
    print ("$allheaders{$kallheaders[$i]}\t($kallheaders[$i])\tWarning!\n");
  }
}
print ("number of fasta headers found in the $fileSe....: $n\n") if ($m > 0);
print ("number of fasta headers not found in the $fileSe: $m\n") if ($m > 0);
#die ("bien!\n");
#-------------------------------------------------------------------------------

sub capitalize {
  my $word = $_[0];
  my @words = split (/\s+/, $word);
  my $newword = ();
  foreach my $w (@words){
    if ($w =~ /-/){
      my @words2 = split (/-/, $w);
      my $newword2 = ();
      foreach my $w2 (@words2){
        $w2 =~ /^(\w)/;
        my $c2 = $1;
        $c2 =~ tr/a-z/A-Z/;
        my @l2 = split (//, $w2);
        if ($newword2 =~ /\w/){
          $newword2 = $newword2.'-'.$c2;
        }  else {
          $newword2 = $c2;
        }
        for (my $i = 1; $i <= $#l2; $i++){
          if ($i < $#l2){
            $newword2 = $newword2.$l2[$i];
          } else {
            $newword2 = $newword2.$l2[$i].'-';
          }
        }
        $newword2 =~ s/-+$//;
      }
      $w = $newword2;
    }
    $w =~ /^(\w)/;
    my $c = $1;
    $c =~ tr/a-z/A-Z/;
    my @l = split (//, $w);
    if ($newword =~ /\w/){
      $newword = $newword.' '.$c;
    }  else {
      $newword = $c;
    }
    for (my $i = 1; $i <= $#l; $i++){
      if ($i < $#l){
        $newword = $newword.$l[$i];
      } else {
        $newword = $newword.$l[$i].' ';
      }
    }
    $newword =~ s/\s+$//;
  }
  if ($newword eq 'Usa'){
    $newword = 'USA';
  } elsif ($newword eq 'Kwazulu-Natal'){
    $newword = 'KwaZulu-Natal';
  } elsif ($newword eq 'O\'higgins'){
    $newword = 'O\'Higgins';
  } elsif ($newword eq 'Provence-Alpes-Côte D\'azur'){
    $newword = 'Provence-Alpes-Côte d\'Azur';
  } elsif ($newword eq 'Valle D\'aosta'){
    $newword = 'Valle D\'Aosta';
  } elsif ($newword eq 'Aix-En-Provence'){
   $newword = 'Aix-en-Provence';
  } elsif ($newword eq 'Asnières-Sur-Seine'){
   $newword = 'Asnières-sur-Seine';
  } elsif ($newword eq 'Beko\'a'){
   $newword = 'Beko\'A';
  } elsif ($newword eq 'Bela Ledec Na Sazavou'){
   $newword = 'Bela - Ledec Na Sazavou';
  } elsif ($newword eq 'Benalua de Las Villas'){
   $newword = 'Benalua de las Villas';
  } elsif ($newword eq 'Bernieres-Le-Patry'){
   $newword = 'Bernieres-le-Patry';
  } elsif ($newword eq 'Bois-De-Villers'){
   $newword = 'Bois-de-Villers';
  } elsif ($newword eq 'Bonrepos I Mirambell'){
   $newword = 'Bonrepos i Mirambell';
  } elsif ($newword eq 'Boulogne Sur Mer'){
   $newword = 'Boulogne sur Mer';
  } elsif ($newword eq 'Bourg-En-Bresse'){
   $newword = 'Bourg-en-Bresse';
  } elsif ($newword eq 'Braine-L\'alleud'){
   $newword = 'Braine-l\'Alleud';
  } elsif ($newword eq 'Braine-Le-Château'){
   $newword = 'Braine-le-Château';
  } elsif ($newword eq 'Braine-Le-Comte'){
   $newword = 'Braine-le-Comte';
  } elsif ($newword eq 'Bry Sur Marne'){
   $newword = 'Bry sur Marne';
  } elsif ($newword eq 'Cagnes-Sur-Mer'){
   $newword = 'Cagnes-sur-Mer';
  } elsif ($newword eq 'Caldes D\'estrac'){
   $newword = 'Caldes d\'Estrac';
  } elsif ($newword eq 'Canet D\'en Berenguer'){
   $newword = 'Canet d\'en Berenguer';
  } elsif ($newword eq 'Canoves I Samalus'){
   $newword = 'Canoves i Samalus';
  } elsif ($newword eq 'Chalon Sur Saone'){
   $newword = 'Chalon sur Saone';
  } elsif ($newword eq 'Chanteloup-En-Brie'){
   $newword = 'Chanteloup-en-Brie';
  } elsif ($newword eq 'Contamine-Sur-Arve'){
   $newword = 'Contamine-sur-Arve';
  } elsif ($newword eq 'Corro D\'avall'){
   $newword = 'Corro d\'Avall';
  } elsif ($newword eq 'Crouy En Thelle'){
   $newword = 'Crouy en Thelle';
  } elsif ($newword eq 'Crépy En Valois'){
   $newword = 'Crépy en Valois';
  } elsif ($newword eq 'Desoto Parish'){
   $newword = 'DeSoto Parish';
  } elsif ($newword eq 'Ermeton-Sur-Biert'){
   $newword = 'Ermeton-sur-Biert';
  } elsif ($newword eq 'Etables Sur Mer'){
   $newword = 'Etables sur Mer';
  } elsif ($newword eq 'Faulx-Les-Tombes'){
   $newword = 'Faulx-les-Tombes';
  } elsif ($newword eq 'Fontaine-L\'Évêque'){
   $newword = 'Fontaine-l\'Évêque';
  } elsif ($newword eq 'Forchies-La-Marche'){
   $newword = 'Forchies-la-Marche';
  } elsif ($newword eq 'Fort-De-France'){
   $newword = 'Fort-de-France';
  } elsif ($newword eq 'Givat Ye\'arim'){
   $newword = 'Givat Ye\'Arim';
  } elsif ($newword eq 'Gondrecourt-Le-Chateau'){
   $newword = 'Gondrecourt-le-Chateau';
  } elsif ($newword eq 'Hauts-De-Seine'){
   $newword = 'Hauts-de-Seine';
  } elsif ($newword eq 'Heist-Op-Den-Berg'){
   $newword = 'Heist-op-den-Berg';
  } elsif ($newword eq 'Herk-De-Stad'){
   $newword = 'Herk-de-Stad';
  } elsif ($newword eq 'Houtain-Le-Val'){
   $newword = 'Houtain-le-Val';
  } elsif ($newword eq 'I\'billin'){
   $newword = 'I\'Billin';
  } elsif ($newword eq 'Ivry-Sur-Seine'){
   $newword = 'Ivry-sur-Seine';
  } elsif ($newword eq 'Jemeppe-Sur-Sambre'){
   $newword = 'Jemeppe-sur-Sambre';
  } elsif ($newword eq 'Juvisy-Sur-Orge'){
   $newword = 'Juvisy-sur-Orge';
  } elsif ($newword eq 'Ka\'abiyye-Tabbash-Hajajre'){
   $newword = 'Ka\'Abiyye-Tabbash-Hajajre';
  } elsif ($newword eq 'Kematen In Tirol'){
   $newword = 'Kematen in Tirol';
  } elsif ($newword eq 'Kiryat Ye\'arim'){
   $newword = 'Kiryat Ye\'Arim';
  } elsif ($newword eq 'Kostelec N. ?ernými Lesy'){
   $newword = 'Kostelec N. Černými Lesy';
  } elsif ($newword eq 'L\'aquila'){
   $newword = 'L\'Aquila';
  } elsif ($newword eq 'La Roche-Sur-Yon'){
   $newword = 'La Roche-sur-Yon';
  } elsif ($newword eq 'Le Puy-En-Velay'){
   $newword = 'Le Puy-en-Velay';
  } elsif ($newword eq 'Les Sables D\'olonne'){
   $newword = 'Les Sables D\'Olonne';
  } elsif ($newword eq 'Llica D\'amunt'){
   $newword = 'Llica D\'Amunt';
  } elsif ($newword eq 'Loon Op Zand'){
   $newword = 'Loon op zand';
  } elsif ($newword eq 'Lu\'an'){
   $newword = 'Lu\'An';
  } elsif ($newword eq 'Mabu\'im'){
   $newword = 'Mabu\'Im';
  } elsif ($newword eq 'Mantes-La-Jolie'){
   $newword = 'Mantes-la-Jolie';
  } elsif ($newword eq 'Matrei Am Brenner'){
   $newword = 'Matrei am Brenner';
  } elsif ($newword eq 'Mcculloch County'){
   $newword = 'McCulloch County';
  } elsif ($newword eq 'Mcdonough County'){
   $newword = 'McDonough County';
  } elsif ($newword eq 'Mchenry County'){
   $newword = 'McHenry County';
  } elsif ($newword eq 'Mehun Sur Yevre'){
   $newword = 'Mehun sur Yevre';
  } elsif ($newword eq 'Monceau-Sur-Sambre'){
   $newword = 'Monceau-sur-Sambre';
  } elsif ($newword eq 'Montignies-Sur-Sambre'){
   $newword = 'Montignies-sur-Sambre';
  } elsif ($newword eq 'Montigny Le Bretonneux'){
   $newword = 'Montigny le Bretonneux';
  } elsif ($newword eq 'Montigny-Le-Tilleul'){
   $newword = 'Montigny-le-Tilleul';
  } elsif ($newword eq 'Montval Sur Loir'){
   $newword = 'Montval sur Loir';
  } elsif ($newword eq 'N\'dorola'){
   $newword = 'N\'Dorola';
  } elsif ($newword eq 'Neuilly Sur Seine'){
   $newword = 'Neuilly sur Seine';
  } elsif ($newword eq 'Noisy Le Roi'){
   $newword = 'Noisy le Roi';
  } elsif ($newword eq 'Notre-Dame-De-Sanilhac'){
   $newword = 'Notre-Dame-de-Sanilhac';
  } elsif ($newword eq 'Noyal Chatillon Sur Seiche'){
   $newword = 'Noyal Chatillon sur Seiche';
  } elsif ($newword eq 'Ottignies-Louvain-La-Neuve'){
   $newword = 'Ottignies-Louvain-la-Neuve';
  } elsif ($newword eq 'Padre Las Casas'){
   $newword = 'Padre las Casas';
  } elsif ($newword eq 'Palau Solita I Plegamans'){
   $newword = 'Palau Solita i Plegamans';
  } elsif ($newword eq 'Pont-?-Celles'){
   $newword = 'Pont-à-Celles';
  } elsif ($newword eq 'Pu\'er'){
   $newword = 'Pu\'Er';
  } elsif ($newword eq 'Ramsau Im Zillertal'){
   $newword = 'Ramsau im Zillertal';
  } elsif ($newword eq 'Romilly Sur Seine'){
   $newword = 'Romilly sur Seine';
  } elsif ($newword eq 'Rouziers-De-Touraine'){
   $newword = 'Rouziers-de-Touraine';
  } elsif ($newword eq 'Ruda ?ląska'){
   $newword = 'Ruda Śląska';
  } elsif ($newword eq 'S\'agaro'){
   $newword = 'S\'Agaro';
  } elsif ($newword eq 'Saint Germain En Laye'){
   $newword = 'Saint Germain en Laye';
  } elsif ($newword eq 'Saint Ouen L\'aumone'){
   $newword = 'Saint Ouen l\'Aumone';
  } elsif ($newword eq 'Saint Valery En Caux'){
   $newword = 'Saint Valery en Caux';
  } elsif ($newword eq 'Saint-Gilles-Croix-De-Vie'){
   $newword = 'Saint-Gilles-Croix-de-Vie';
  } elsif ($newword eq 'Saint-Jean-De-Bournay'){
   $newword = 'Saint-Jean-de-Bournay';
  } elsif ($newword eq 'Saint-Julien-En-Genevois'){
   $newword = 'Saint-Julien-en-Genevois';
  } elsif ($newword eq 'Saint-Thibault-Des-Vignes'){
   $newword = 'Saint-Thibault-des-Vignes';
  } elsif ($newword eq 'Saint-Vallier-De-Thiey'){
   $newword = 'Saint-Vallier-de-Thiey';
  } elsif ($newword eq 'Sanary-Sur-Mer'){
   $newword = 'Sanary-sur-Mer';
  } elsif ($newword eq 'Santa Barbara D\'oeste'){
   $newword = 'Santa Barbara D\'Oeste';
  } elsif ($newword eq 'Santa Croce Di Magliano'){
   $newword = 'Santa Croce di Magliano';
  } elsif ($newword eq 'Seefeld In Tirol'){
   $newword = 'Seefeld in Tirol';
  } elsif ($newword eq 'Sha\'ab'){
   $newword = 'Sha\'Ab';
  } elsif ($newword eq 'Spittal An Der Drau'){
   $newword = 'Spittal an der Drau';
  } elsif ($newword eq 'Steinach Am Brenner'){
   $newword = 'Steinach am Brenner';
  } elsif ($newword eq 'Strass Im Zillertal'){
   $newword = 'Strass im Zillertal';
  } elsif ($newword eq 'Suchy Las'){
   $newword = 'Suchy las';
  } elsif ($newword eq 'Talmei Yehi\'el'){
   $newword = 'Talmei Yehi\'El';
  } elsif ($newword eq 'Val D\'oise'){
   $newword = 'Val D\'Oise';
  } elsif ($newword eq 'Verrières-Le-Buisson'){
   $newword = 'Verrières-le-Buisson';
  } elsif ($newword eq 'Villers-La-Ville'){
   $newword = 'Villers-la-Ville';
  } elsif ($newword eq 'Vitry Le Francois'){
   $newword = 'Vitry le Francois';
  } elsif ($newword eq 'Xangri-La'){
   $newword = 'Xangri-la';
  } elsif ($newword eq 'Zell Am See'){
   $newword = 'Zell am See';
  } elsif ($newword eq 'Ząbkowice ?ląskie'){
   $newword = 'Ząbkowice Śląskie';
  } elsif ($newword eq 'Ethekwini'){
   $newword = 'eThekwini';
  } elsif ($newword eq 'Ilembe'){
   $newword = 'iLembe';
  } elsif ($newword eq 'Umgungundlovu'){
   $newword = 'uMgungundlovu';
  } elsif ($newword eq 'Umkhanyakude'){
   $newword = 'uMkhanyakude';
  } elsif ($newword eq 'Umzinyathi'){
   $newword = 'uMzinyathi';
  } elsif ($newword eq 'Uthukela'){
   $newword = 'uThukela';
  } elsif ($newword =~ /^?uble$/){
   $newword = 'Ñuble';
  } elsif ($newword =~ /^?uñoa$/){
   $newword = 'Ñuñoa';
  } elsif ($newword =~ /Sobral de Monte Agra/){
   $newword = 'Sobral de Monte Agraco';
  } elsif ($newword =~ /elinac/){
   $newword = 'Čelinac';
  } elsif ($newword =~ /dzkie/){
   $newword = 'Łódzkie';
  } elsif ($newword =~ /Kostelec .+ Lesy/){
   $newword = 'Kostelec N. Černými Lesy';
  } elsif ($newword =~ /Pont.+Celles/){
   $newword = 'Pont-à-Celles';
  } elsif ($newword =~ /Ruda.+ska/){
   $newword = 'Ruda Śląska';
  } elsif ($newword =~ /bkowice.+skie/){
   $newword = 'Ząbkowice Śląskie';
  } elsif ($newword =~ /^.+n.+tice$/){
   $newword = 'Únětice';
  } elsif ($newword =~ /^.+erve.+ Kostelec$/){
   $newword = 'Červený Kostelec';
  } elsif ($newword =~ /^.+er.+any$/ && $newword !~ /Germany/){
   $newword = 'Čerčany';
  } elsif ($newword =~ /^.+esk.+ Bud.+jovice$/){
   $newword = 'České Budějovice';
  } elsif ($newword =~ /^.+esk.+ Krumlov$/){
   $newword = 'Český Krumlov';
  } elsif ($newword =~ /^.+any$/){
  	if ($newword !~ /Surany/ && $newword !~ /Germany/ && $newword !~ /^Do.+any$/ &&
  	    $newword !~ /Piestany/ && $newword !~ /Topolcany/ && $newword !~ /Tuscany/ &&
  	    $newword !~ /Bethany/ && $newword !~ /^Chr.+any$/ && $newword !~ /Velke Ulany/){
   			$newword = 'Říčany';
   	}
  } elsif ($newword =~ /^.+umavsk.+ Ho.+tice$/){
   $newword = 'Šumavské Hoštice';
 	} elsif ($newword =~ /Gouy-Lez-Piéton/){
	 $newword = 'Gouy-lez-Piéton';
 	} elsif ($newword =~ /Saint-Josse-Ten-Noode/){
	 $newword = 'Saint-Josse-ten-Noode';
  #---------------------------------------------------------------------------------------
  # If there are more misspelled names, you have to add them here:

  # } elsif ($newword =~ /misspelled name/){
  # $newword = 'original name';
    } elsif ($newword =~ /Marchienne-Au-Pont/){
    	$newword = 'Marchienne-au-Pont';
  #---------------------------------------------------------------------------------------

  }
  $newword =~ s/ And / and /;
  $newword =~ s/ Of / of /;
  $newword =~ s/ The / the /;
  $newword =~ s/ Del / del /;
  $newword =~ s/ De / de /;
  $newword =~ s/ La / la /;
  $newword =~ s/ Y / y /;
  $newword =~ s/ Los / los /;
  $newword =~ s/ Las / las /;
  $newword =~ s/ Nad / nad /;
  $newword =~ s/ Do / do /;
  if ($newword eq '24 de Diciembre'){
   $newword = '24 De Diciembre';
  } elsif ($newword eq 'Jerez de la Frontera'){
   $newword = 'Jerez De La Frontera';
  } elsif ($newword eq 'L\'ametlla del Valles'){
  $newword = 'L\'Ametlla del Valles';
  } elsif ($newword eq 'L\'hospitalet de Llobregat'){
    $newword = 'L\'Hospitalet de Llobregat';
  } elsif ($newword eq 'La Bisbal de L\'emporda'){
    $newword = 'La Bisbal de l\'Emporda';
  } elsif ($newword eq 'Sao Jose do Brejo Do Cruz'){
    $newword = 'Sao Jose do Brejo do Cruz';
  } elsif ($newword eq 'Torres de Elorz'){
    $newword = 'Torres De Elorz';
  }
  return ($newword);
}
