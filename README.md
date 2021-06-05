# Mexstrain
-----------

### Important: GISAID changed its file formats, we are updating our scripts so they become useful again, we are working on it! 
Perl scripts to manipulate data derived from GISAID and Nextstrain.

The scripts in this repository facilitate the manipulation of data (metadata and fasta sequences) downloaded from GISAID to make a Nextstrain analysis. In particular, the scripts allow to subsample sequences from Nextstrain and GISAID to make a Nextstrain analysis in a given Country (Figure 1). 

<p align="center">
  <img width="1032" height="578" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure1-Mexstrain2.png">
</p>

### Collect data
First collect the data. Go to the latest global analysis provided by [Nextstrain](https://nextstrain.org/ncov/global), scroll to the bottom of the page, select 'DOWNLOAD DATA' and then 'DOWNLOAD ALL METADATA (TSV)'. You will get a file named nextstrain_ncov_global_metadata.tsv. 

Next, go to [GISAID](https://www.gisaid.org) and download all fasta sequences (sequences.fasta) and asociated metadata (metadata.tsv). You will find these files in 'Downloads -> Downoads packages'. Also download Spike protein sequences in FASTA format (spikeprot####.fasta). You can find these sequences in 'Downloads -> Alignment and proteins'.

In summary, you will have to download from Nextstrain and GISAID the following files:

* nextstrain_ncov_global_metadata.tsv # latest global analysis provided by Nextrain

* sequences.fasta # fasta genome sequences from GISAID

* metadata.tsv # metadata from GISAID

* spikeprot####.fasta # Spike protein sequences from GISAID

### Curate the files containing the names of geographic locations 

We will asume that you have a local Nexstrain installation. Within the Nexstrain installation, the color_ordering.tsv file contains the names of geographic localities. These names are organized into: regions, countries, division and localities. You can find the color_ordering.tsv file in the directory ncov/defaults/color_ordering.tsv. The first thing to do is to curate this file to be sure that the names between the color_ordering.tsv and metadata.tsv files are the same. For this we use the script curatelocationname.pl. To run the script write:

```
$ perl curatelocationnames.pl color_ordering.tsv metadata.tsv Mexico substitute.tsv
```

In our example data, the first time you run the curatelocationname.pl script you will get the following output:

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

Based on the above result, you have to decide: i) if you want to change the names of the geographic localities in the metadata.tsv file so they match those of the color_ordering.tsv file; or ii) if you want to change the names of the color_ordering.tsv file so they match those of the metadata.tsv file; or iii) if you have to add some names to the color_ordering.tsv file.

In our example, we first are going to change the name of the geographic localities in the metadata.tsv file so they match those of the color_ordering.tsv file. We do this by creating a two column text file containing the names of the geographic localities to be substituted. In the first column we write the name to be substituted and in the second column we write the substitution name. The columns must be separated by tabs. Write all names in lowercase. An example of a substitute.tsv file is shown next:

```
state of mexico	estado de mexico
coahuila de zaragoza	coahuila
ciudad de mexico	mexico city
yucat	yucatan
```
As you can see, we substituted 'state of mexico' by 'estado de mexico' and 'coahuila de zaragoza' by 'coahuila'. It is worth mentioning the case of 'yucatan'. In the color_ordering.tsv file the State is written as 'Yucatan' however in the metadata.tsv is written as 'Yucatán' (with accent in the 'a'). By general rule, it is better to avoid accentuated vowels. Because we use regular expression within the script, to replace the world 'Yucatán' by 'Yucatan' it is enough to write only the first part: 'yucat'. 


### Work in progress... June 02, 2021 - last update

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

Supplementary_Tables_1_2_3.xlsx. Barona-Gomez et al. Phylogenomics and population genomics of SARS-CoV-2 in Mexico reveals variants of interest (VOI) and a mutation in the Nucleocapsid protein associated with symptomatic versus asymptomatic carriers. (submited).

