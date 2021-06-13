# Mexstrain
-----------

Perl scripts to manipulate data derived from GISAID and Nextstrain.

The scripts in this repository facilitate the manipulation of data (metadata and fasta sequences) downloaded from GISAID to make a Nextstrain analysis. In particular, the scripts allow to subsample sequences from Nextstrain and GISAID to make a Nextstrain analysis focused in a given Country (Figure 1). 

<p align="center">
  <img width="720" height="405" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure-1-Mexstrain.jpeg">
</p>

### Collect data

First collect the data. Go to the latest global analysis provided by [Nextstrain](https://nextstrain.org/ncov/global), scroll to the bottom of the page, select 'DOWNLOAD DATA' and then 'DOWNLOAD ALL METADATA (TSV)'. You will get a file named nextstrain_ncov_global_metadata.tsv. 

Next, go to [GISAID](https://www.gisaid.org) and download all fasta sequences (sequences.fasta) and asociated metadata (metadata.tsv). You will find these files in 'Downloads -> Downoads packages'. Also download Spike protein sequences in FASTA format (spikeprot####.fasta). You can find these sequences in 'Downloads -> Alignment and proteins'.

Also in [GISAID](https://www.gisaid.org), download all the metadata of the genome sequences from the country (or any other geographical region) on which you would like to focus your Nextstrain analysis. In this case, we will download all complete and high coverage sequences from Mexico (gisaid_hcov-19_2021_##_##_##.tsv). You can find this information in 'Search -> Location -> North America -> Mexico' and by clicking in the boxes 'complete' and 'high coverage' and when asked, download the 'Patient status metadata'.

In summary, you will have to download from Nextstrain and GISAID the following files:

* nextstrain_ncov_global_metadata.tsv # latest global analysis provided by Nextrain

* sequences.fasta # fasta genome sequences from GISAID

* metadata.tsv # metadata from GISAID

* spikeprot####.fasta # Spike protein sequences from GISAID

* gisaid_hcov-19_2021_##_##_##.tsv # metadata associated to the genomes of interest from GISAID

### Curate the files containing the names of geographic localities 

We will asume that you have a local Nexstrain installation. Within the Nexstrain installation, the color_ordering.tsv file contains the names of geographic localities. These names are organized into: region, country, division and location. You can find the color_ordering.tsv file in the directory ncov/defaults/color_ordering.tsv. The first thing to do is to curate this file to be sure that the names between the color_ordering.tsv and metadata.tsv files are the same. For this we use the script curate_names.pl. To run the script write:

```
$ perl curate_names.pl color_ordering.tsv metadata.tsv Mexico
```

In our example data, the first time you run the curate_names.pl script you will get the following output:

```
No substitute.tsv file provided

names in metadata.tsv: North America / Mexico / State of Mexico
lowercase names......: north america / mexico / state of mexico
Waring! name not found in color_ordering.original.tsv: 'state of mexico'

names in metadata.tsv: North America / Mexico / Coahuila de Zaragoza
lowercase names......: north america / mexico / coahuila de zaragoza
Waring! name not found in color_ordering.original.tsv: 'coahuila de zaragoza'

names in metadata.tsv: North America / Mexico / State of Mexico / Nicolas Romero
lowercase names......: north america / mexico / state of mexico / nicolas romero
Waring! name not found in color_ordering.original.tsv: 'state of mexico'

names in metadata.tsv: North America / Mexico / Ciudad de Mexico
lowercase names......: north america / mexico / ciudad de mexico
Waring! name not found in color_ordering.original.tsv: 'ciudad de mexico'

names in metadata.tsv: North America / Mexico / Jalisco / Puerto Vallarta
lowercase names......: north america / mexico / jalisco / puerto vallarta
Waring! name not found in color_ordering.original.tsv: 'puerto vallarta'

names in metadata.tsv: North America / Mexico / Jalisco / Zapopan
lowercase names......: north america / mexico / jalisco / zapopan
Waring! name not found in color_ordering.original.tsv: 'zapopan'

names in metadata.tsv: North America / Mexico / Yucatán
lowercase names......: north america / mexico / yucatán
Waring! name not found in color_ordering.original.tsv: 'yucatán'

------------------------------------------------------------------------
The following names don't match any name in the color_ordering.tsv file:

'ciudad de mexico'
'coahuila de zaragoza'
'puerto vallarta'
'state of mexico'
'yucatán'
'zapopan'

------------------------------------------------------------------------
Provide a substitution.tsv file or add the names to color_ordering.tsv.
See https://github.com/luisdelaye/Mexstrain/ for more details.
------------------------------------------------------------------------
```

Based on the above result, you have to decide: i) if you want to change the names of the geographic localities in the metadata.tsv file so they match those of the color_ordering.tsv file; ii) if you want to change the names of the color_ordering.tsv file so they match those of the metadata.tsv file; or iii) if you have to add some names to the color_ordering.tsv file.

In our example, we first are going to change the name of the geographic localities in the metadata.tsv file so they match those of the color_ordering.tsv file. We do this by creating a two column text file containing the names of the geographic localities to be substituted. In the first column we write the name to be substituted and in the second column we write the substitution name. The columns must be separated by tabs. Write all names in lowercase. An example of a substitute.tsv file is shown next:

```
state of mexico	estado de mexico
coahuila de zaragoza	coahuila
ciudad de mexico	mexico city
yucat	yucatan
```

As you can see, we substituted 'state of mexico' by 'estado de mexico' and 'coahuila de zaragoza' by 'coahuila'. It is worth mentioning the case of 'yucatan'. In the color_ordering.tsv file the State is written as 'Yucatan' however in the metadata.tsv is written as 'Yucatán' (with accent in the 'a'). By general rule, it is better to avoid accentuated vowels. Because we use regular expression within the script, to replace the world 'Yucatán' by 'Yucatan' it is enough to write only the first part of the name: 'yucat' and the script will do the rest. 

If you would like to change the names of the color_ordering.tsv file instead, simply open the file with a text editor (like [ATOM](https://atom.io)) and change it. Also avoid writting vowels with accents.

Next, you will have to add the names of 'puerto vallarta' and 'zapopan' to the color_ordering.tsv file. Note that these names correspond to the category: 'location' within the 'division' of Jalisco. Therefore you will have to add the following text:

```
# Jalisco
location	Puerto Vallarta
location	Zapopan
```

Next, you run the script again to see if there are no more mismatches:

```
$ perl curate_names.pl color_ordering.tsv metadata.tsv Mexico substitute.tsv
```

If there are no more mismatches you should get the following ouptup:

```
All names in metadata.tsv have a match in color_ordering.tsv
```

Finally, because you added two new localities and changed the names of four divisions in the color_ordering.tsv file, you have to make the same changes to the lat_longs.tsv file within Nextstrain. You can find this file within: ncov/defaults/lat_longs.tsv. Next we show these names within the lat_longs.tsv file:

```
division	Coahuila	27.302222	-102.044722
division	Estado de Mexico	19.354167	-99.630833
division	Mexico City	19.419444	-99.145556
division	Yucatan	20.833333	-89

location	Puerto Vallarta	20.617	-105.23018
location	Zapopan	20.720278	-103.391944
```

The curate_names.pl script will output a file named outfile.tsv. This file is the new metadata. It contains the new geographic names, all in lowercase. Change the name of this file:

```
$ mv outfile.tsv metadata.e1.tsv
```

A final tweak to the color_ordering.tsv file is necessary before we go to the next step. Open the color_ordering.tsv file with a text editor (like [ATOM](https://atom.io)) and replace 'Sobral de Monte Agrac O' by 'Sobral de Monte Agraco'. There is a hidden caracter in the last word 'Agrac O' that has to be removed. 

### Format the metadata file for Nextstrain

Next, we are going to create the metadata file in the format required for Nextstrain. But first, we need to prepare some files:

```
$ grep '>' sequences.fasta > sequences.fasta.headers.txt
$ grep '>' spikeprot####.fasta spikeprot####.fasta.headers.txt 
```

Now, run the script format_metadata.pl:

```
$ perl format_metadata.pl metadata.e1.tsv sequences.fasta.headers.txt spikeprot####.fasta.headers.txt color_ordering.tsv
```

It is possible that you get the following warning message:


```
Warning! misspelled names:
Category	(right name)	(misspelled name)
Location	(Šumavské Hoštice)	(?umavské Hoštice)

There are misspelled names
You have to open create_metadata.pl and code Perl to fix the problem
Go to the bottom of the file and where indicated, code:

  } elsif ($newword =~ /misspelled name/){
    $newword = 'right name';

You may need to use pattern matching to contend with unusual characters
Press enter to continue
```

If you get this message, you will have to open the format_metadata.pl file and go to the bottom to find the place where you have to code for the rigth name. For instance, in the example above you would have to code the following to fix the name:


```
  } elsif ($newword =~ /^.+umavsk.+ Ho.+tice$/){
   $newword = 'Šumavské Hoštice';
```

Notice that I used pattern matching to match the misspelled name: '?umavské Hoštice'.

If you don't get the warning message, simply rename the outfile.tsv


```
$ mv outfile.tsv metadata.e2.tsv 
```

### Sample sequences for Nexstrain analysis

The following script will sample N number of sequences of each [Pangolin](https://cov-lineages.org/pangolin.html) lineage per month. The script samples all different available lineages per month. Also, the script uses a random number generator to select which genomes to sample. If you use the same number in subsequent runs, you will get the same set of sequences. In our example, we will select at most 5 sequences of each Pangolin lineage per month and use the number 31416 to seed the random number generator.

Before running the script, we have to delete hidden new line characters:

```
$ perl replacemc.pl gisaid_hcov-19_2021_##_##_##.tsv 
$ mv gisaid_hcov-19_2021_##_##_##.tsv.e1 gisaid_hcov-19_2021_##_##_##.e1.tsv 
```

Now, run the script to sample the sequences:

```
$ perl selectgenomes.pl gisaid_hcov-19_2021_##_##_##.e1.tsv 31416 5
$ mv outfile.tsv gisaid_hcov-19_2021_##_##_##.e1.selected.tsv
```

The script will print to the screen: collection dates, Pangolin lineages, Clades and the EPI ISL number of selected genomes.

Now, you may whant to sample the genomes downloaded from Nextstrain global analysis. We can us the same seed to generate random numbers and select at most 5 sequences of each Pangolin lineage per month:

```
$ perl selectgenomesN.pl nextstrain_ncov_global_metadata.tsv 31416 5
$ mv outfile.tsv nextstrain_ncov_global_metadata.selected.tsv
```

### Create the sequence and metadata files for Nexstrain analysis

Now we are going to join selected genome sequences (and their associated metadata) from GISAID and Nexstrain into a file (each) for Nextstrain analysis. This will take a while...

```
$ perl integrategenomes.pl gisaid_hcov-19_2021_05_13_21.e1.selected.tsv nextstrain_ncov_global_metadata.selected.tsv metadata.e2.tsv sequences.fasta
out: outfile.tsv, outfile.fasta
$ mv outfile.tsv metadata.selected.tsv
$ mv outfile.fasta sequences.selected.fasta
```

Now, check wheter the sequences used as external group by Nextstrain are among those that are selected:

```
$ grep 'EPI_ISL_402125' metadata.selected.tsv 
$ grep 'EPI_ISL_406798' metadata.selected.tsv 
```

If they are not, includ them with the following script:

```
$ perl addexternalgroup.pl metadata.selected.tsv
$ mv outfile.tsv metadata.selected.e1.tsv
$ cat sequences.selected.fasta EPI_ISL_402125.fasta EPI_ISL_406798.fasta > sequences.selected.e1.fasta
```

Note that you have to download the sequences EPI_ISL_402125 and EPI_ISL_406798 from [GISAID](https://www.gisaid.org) before concatenating the fasta files. Make sure that the sequence EPI_ISL_402125 contains the header: hCoV-19/Wuhan/Hu-1/2019|2019-12-31|2020-01-12 and the sequence EPI_ISL_406798 contains the header hCoV-19/Wuhan/WH01/2019|2019-12-26|2020-01-30.

Now, a final tweaks to the metadata file:

```
$ perl addcolumns.pl metadata.selected.tsv
$ mv outfile.tsv metadata.selected.tsv
$ perl substitutename.pl metadata.selected.tsv 
$ mv outfile metadata.selected.tsv
$ perl substitutename.pl sequences.selected.fasta
$ mv outfile sequences.selected.fasta
```

With this, you have the sequence and the metadata files required to run a Nextstrain analysis:

```
metadata.selected.tsv
sequences.selected.fasta
```

But we haven't finished yet. You may want to tell Nextstrain to include in the analysis all the sequences from the country (in this case Mexico) you which to focus on. For this you can use the following script:

```
$ perl addtoinclude.pl sequences.selected.fasta Mexico > add_toinclude.txt
```

Now you will simply add the names of the sequences in the file add_toinclude.txt to the file ncov/defaults/include.txt.

Now, run Nextstrain!


Supplementary material
----------------------

Supplementary_Tables_1_2_3.xlsx. Barona-Gomez et al. Phylogenomics and population genomics of SARS-CoV-2 in Mexico during the pre-vaccination stage reveals variants of interest B.1.1.28.4, B.1.1.222 or B.1.1.519 and B.1.243 with mutations in the Spike protein and the Nucleocapsid. (submited).

