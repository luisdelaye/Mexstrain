# Mexstrain
-----------

### Important: GISAID changed its file formats, we are updating our scripts so they become useful again, we are working on it! last update: June 10, 2021
Perl scripts to manipulate data derived from GISAID and Nextstrain.

The scripts in this repository facilitate the manipulation of data (metadata and fasta sequences) downloaded from GISAID to make a Nextstrain analysis. In particular, the scripts allow to subsample sequences from Nextstrain and GISAID to make a Nextstrain analysis focused in a given Country (Figure 1). 

<p align="center">
  <img width="1032" height="578" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure-1-Mexstrain.png">
</p>

### Collect data
First collect the data. Go to the latest global analysis provided by [Nextstrain](https://nextstrain.org/ncov/global), scroll to the bottom of the page, select 'DOWNLOAD DATA' and then 'DOWNLOAD ALL METADATA (TSV)'. You will get a file named nextstrain_ncov_global_metadata.tsv. 

Next, go to [GISAID](https://www.gisaid.org) and download all fasta sequences (sequences.fasta) and asociated metadata (metadata.tsv). You will find these files in 'Downloads -> Downoads packages'. Also download Spike protein sequences in FASTA format (spikeprot####.fasta). You can find these sequences in 'Downloads -> Alignment and proteins'.

In summary, you will have to download from Nextstrain and GISAID the following files:

* nextstrain_ncov_global_metadata.tsv # latest global analysis provided by Nextrain

* sequences.fasta # fasta genome sequences from GISAID

* metadata.tsv # metadata from GISAID

* spikeprot####.fasta # Spike protein sequences from GISAID

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

### Create the metadata file for Nextstrain

Next, we are going to create the metadata file in the format required for Nextstrain. But first, we need to prepare some files:

```
$ grep '>' sequences.fasta > sequences.fasta.headers.txt
$ grep '>' spikeprot####.fasta spikeprot####.fasta.headers.txt 
```

Now, run the script create_metadata.pl:

```
$ perl create_metadata.pl metadata.e1.tsv sequences.fasta.headers.txt spikeprot####.fasta.headers.txt color_ordering.tsv
```

It is possible that you may get the following warning message:

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

If you get this message, you will have to open the create_metadata.pl file and go to the bottom to find the place where you have to code for the rigth name. For instance, in the example above you would have to code the following to fix the name:

```
  } elsif ($newword =~ /^.+umavsk.+ Ho.+tice$/){
   $newword = 'Šumavské Hoštice';
```

Notice that I used pattern matching to match the misspelled name: '?umavské Hoštice'.

If you don't get the warning message, simply rename the outfile.tsv

```
$ mv outfile.tsv metadata.e2.tsv 

```



### Work in progress... 

Delete hiden newline characters

$ perl replacemc.pl gisaid_hcov-19_Mex.fasta

$ mv gisaid_hcov-19_Mex.fasta.e1 gisaid_hcov-19_Mex.e1.fasta

$ perl replacemc.pl gisaid_hcov-19_Mex.tsv

$ mv gisaid_hcov-19_Mex.tsv.e1 gisaid_hcov-19_Mex.e1.tsv

Get fasta sequences represented in the latest global Nextstrain analysis

$ perl extractncov.pl nextstrain_ncov_global_metadata.tsv sequences.fasta

$ mv outfile.fasta nextstrain_ncov_global_metadata.fasta

Get metadata associated to the latest global Nextstrain analysis

$ perl extractmetadata.pl nextstrain_ncov_global_metadata.fasta metadata.tsv

$ mv outfile nextstrain_ncov_global_metadata.f.tsv

Create a file with the IDs of the sequences from Mexico that are in the latest global Nextstrain analysis

$ perl extractids.pl nextstrain_ncov_global_metadata.f.tsv 17 Mexico

$ mv outfile ncov_Mex_IDs.txt

Create the fasta and metadata files of those sequences in gisaid_hcov-19_Mex.fasta 

$ perl createfiles.pl ncov_Mex_IDs.txt gisaid_hcov-19_Mex.e1.fasta sequences.fasta metadata.tsv gisaid_hcov-19_Mex.e1.tsv

Concatenate the files 

$ cat nextstrain_ncov_global_metadata.f.tsv outfile.txt outfile2.txt > nextstrain_ncov_global_metadata.fc.tsv

$ cat nextstrain_ncov_global_metadata.fasta outfile.fasta outfile2.fasta > nextstrain_ncov_global_metadata.fc.fasta

Move the files nextstrain_ncov_global_metadata.fc.tsv and nextstrain_ncov_global_metadata.fc.fasta to the Nextstrain data/ directory, modify the config.yaml file and run Nextstrain!

Finally, if you would like to be sure that a given set of sequences are included in your Nextstrain analysis, you can use the following script

$ perl toinclude.pl nextstrain_ncov_global_metadata.fc.fasta Mexico > add_to_include.txt

Just add the IDs in add_to_include.txt to the file defaults/include.txt in you local Nextstrain installation.

Accompanying scripts
--------------------

If you would like to create a smaller set of sequences for Nextstrain analysis, you can use the following scripts:

$ perl selectM.pl nextstrain_ncov_global_metadata.tsv N1 N2 > nextstrain_ncov_global_metadata.selected.N2.tsv

out: outfileM

where N1 refers to a column in the nextstrain_ncov_global_metadata.tsv file. Chose N1 = 6 for country. And N2 refers to the maximum number of rows from each category specified by N1. For example, if N1 = 6 and N2 = 10, you will select the first 10 rows (genomes) from each country in the nextstrain_ncov_global_metadata.tsv file.

Next, select the secuences

$ perl selectS.pl outfileM nextstrain_ncov_global_metadata.fasta

out: outfileS

$ mv outfileS  nextstrain_ncov_global_metadata.selected.N2.fasta


Supplementary material
----------------------

Supplementary_Tables_1_2_3.xlsx. Barona-Gomez et al. Phylogenomics and population genomics of SARS-CoV-2 in Mexico during the pre-vaccination stage reveals variants of interest B.1.1.28.4, B.1.1.222 or B.1.1.519 and B.1.243. (submited).

