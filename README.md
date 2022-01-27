# Mexstrain
-----------

# We are updating the scripts, please do not use them until this message disappears!

Perl scripts to manipulate data derived from GISAID and Nextstrain.

Last update: January 10, 2022.

The scripts in this repository facilitate the manipulation of data (metadata and fasta sequences) downloaded from GISAID to make a Nextstrain analysis. In particular, the scripts allow to subsample sequences from Nextstrain and GISAID to make a Nextstrain analysis focused in a specified country (Figure 1). For instance, we used these scripts to create [Mexstrain](http://www.ira.cinvestav.mx/ncov.evol.mex.aspx). We also provide scripts to facilitate visualization of sequences in Microreact. The scripts provided here also facilitate the curation of names from locations, divisions and countries from metadata downloaded from GISAID. This curation is an important step to properly display of sequences in Nextstrain and Microreact.

<p align="center">
  <img width="720" height="405" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure-1-Mexstrain2.jpeg">
</p>

Figure 1. Mexstrain allows to combine information from Nextstrain and GISAID to make a phylodynamic analysis focused on a single country.



Next, we show a roadmap of how to use the scripts to download data from Nextstrain Global Analysis and GISAID, curate the names of metadata files downloaded from GISAID, sample sequences from Nextstrain and GISAID and finally run a local Nextstrain analysis (Figure 2). All the above, to study the evolution of SARS-CoV-2 sequences in a specified country.

<p align="center">
  <img width="720" height="1382" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure-2-Mexstrain.png">
</p>
Figure 2. Roadmap to make a Nextstrain analysis on a specified country.


### Collect data

First collect the data. Go to the latest global analysis provided by [Nextstrain](https://nextstrain.org/ncov/global), scroll to the bottom of the page, select 'DOWNLOAD DATA' and then 'ACKNOWLEDGEMENTS (TSV)'. You will get a file named nextstrain_ncov_gisaid_global_acknowledgements.tsv. 

Next, go to [GISAID](https://www.gisaid.org) and download all FASTA sequences (sequences.fasta) and asociated metadata (metadata.tsv). You will find these files in 'Downloads -> Downoads packages'. Also download Spike protein sequences in FASTA format (spikeprot####.fasta). You can find these sequences in 'Downloads -> Alignment and proteins'. In Figure 3 you can see where to find these files in GISAID. Don't forget to decompress these files.

<p align="center">
  <img width="735.75" height="607.5" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure-3-Mexstrain.png">
</p>
<p style='text-align: right;'> Figure 3. Location of the files sequence.fasta, metadata.tsv and spikeprot####.fasta in GISAID. </p>


Also in [GISAID](https://www.gisaid.org), download all the 'Patient status metadata' associated to the genome sequences from the country (or any other geographical region) on which you would like to focus your Nextstrain analysis. In this case, we will download the metadata from all complete and high coverage sequences from Mexico (gisaid_hcov-19_2022\_##\_##.tsv). You can find this information in 'Search -> Location -> North America -> Mexico' and by clicking in the boxes 'complete' and 'high coverage' and when asked, download the 'Patient status metadata' (Figure 4). 

<p align="center">
  <img width="736.5" height="596.25" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure-4-Mexstrain.png">
</p>
<p style='text-align: right;'> Figure 4. Download all the metadata asociated to the country on which you would like to focus your Nextstrain analysis. </p>


Because you can download a maximum of 10,000 records each time, you may need to download several files, one for each state/division. In the case of Mexico, we need to download one file for each one of the states (Aguascalientes, Baja California, Baja California Sur, etc.) If you like, you can add the name of the state to each of the files (avoid spaces or accents in the name of the files), for example:

```
$ mv gisaid_hcov-19_2022_01_11_01.tsv gisaid_hcov-19_2022_01_11_01_Aguascalientes.tsv
```

Just keep the first part of the filename 'gisaid_hcov-19_2022_' and the extension 'tsv'. Next, you will need to run the script:

```
$ perl concatenate_tsv_files.pl gisaid_hcov-19_2022_
$ mv outfile.tsv gisaid_hcov-19_2022_##_##.tsv
```

Please replace the \_##\_##.tsv with an actual date and move this file to your working directory. Note: you may want to run the above script in a separate directory to avoid having an excess of files in your main working directory (just, don't forget to move to that separate directory all the gisaid_hcov-19_2022_\*.tsv files before running the script). 

In summary, you will have to download from Nextstrain and GISAID the following files:

* nextstrain_ncov_global_metadata.tsv -> latest global analysis provided by Nextrain

* sequences.fasta -> fasta genome sequences downloaded from GISAID

* metadata.tsv -> metadata downloaded from GISAID

* spikeprot####.fasta -> Spike protein sequences from GISAID

* gisaid_hcov-19_2022\_##\_##.tsv -> metadata downloaded from GISAID associated to the genomes of interest

The above files must be in the same directory as the Perl scripts you downloaded from Github.

### Curate the files containing the names of geographic localities 

Now comes the toughest part: to assure that the names of the geographic localities are spelled the same in all files. First, a bit of background. We will asume that you have a local Nextstrain installation. Nextstrain store the name of geographic localities in two files: color_ordering.tsv and lat_longs.tsv. These files live in: ncov/defaults/ wihtin your Nextstrain installation directory. The first file (color_ordering.tsv) is used by Nextstrain to know if a given locality is a 'region', 'country', 'division' or a 'location'; the second file (lat_longs.tsv) keeps the geographic coordinates of all the places found in color_ordering.tsv. These files were prepared by the people from Nextstrain and share the same geographic localities. 

The names of the geographic localities in color_ordering.tsv and lat_longs.tsv have to match those in metadata.tsv. However, this is not always the case because the names in metadata.tsv are captured by many different people around the world and sometimes these people introduce typos. In addition, the names in metadata.tsv can be in diverse lenguages while in color_ordering.tsv most names (but not all!) are in English. In addition, there can be geographic localities in metadata.tsv that are lacking in color_ordering.tsv and lat_longs.tsv. These lacking localities have to be added to color_ordering.tsv and lat_longs.tsv.

To fix the above problem, you can do the following: i) change the names of the geographic localities in the metadata.tsv file so they match those of the color_ordering.tsv and lat_longs.tsv files; ii) change the names in color_ordering.tsv and lat_longs.tsv files so they match those in metadata.tsv; and/or iii) add those extra names in metadata.tsv to color_ordering.tsv and lat_longs.tsv files. At the end, all names from geographic localities in metadata.tsv have to be in color_ordering.tsv and lat_longs.tsv; and every name from a geographic locality in metadata.tsv has to be associated to a geographic coordinate in lat_longs.tsv.

Therefore, the first thing to do is to check whether the names of the geographic localities in metadata.tsv are found in color_ordering.tsv. We will do this specifically for the names of the country on which you would like to focus your Nextstrain analysis (in this case: Mexico). For this we use the script compare_names.pl. We recommend you to make security copies of the original color_ordering.tsv and lat_longs.tsv files (in case you would like to recover the original files) and then make a copy of color_ordering.tsv to your working directory. Then run the script:

```
$ perl compare_names.pl color_ordering.tsv metadata.tsv Mexico
```

This script will check if the names of the geographical localities in metadata.tsv are found in color_ordering.tsv. If a name is not found, it will print a warning message to the screen (Part 1 of the output). This script will also check whether the same name is repeated whithin different geographic contexts (Part 2). We will see later that this may not be an error by itself. In our example data, the first time you run the compare_names.pl script you will get the following output:

```
------------------------------------------------------------------------
Part 1
Are there are names in metadata.tsv lacking in color_ordering.tsv?

Warning! name not found in color_ordering.original.tsv: 'Pabello de A'
context in metadata.tsv: North America / Mexico / Aguascalientes / Pabello de A

Warning! name not found in color_ordering.tsv: 'State of Mexico'
context in metadata.tsv: North America / Mexico / State of Mexico

Warning! name not found in color_ordering.tsv: 'Cancun'
context in metadata.tsv: North America / Mexico / Cancun

Warning! name not found in color_ordering.tsv: 'Cuauhtemoc'
context in metadata.tsv: North America / Mexico / Chihuahua / Cuauhtemoc

Warning! name not found in color_ordering.tsv: 'Huixtla'
context in metadata.tsv: North America / Mexico / Chiapas / Huixtla

Warning! name not found in color_ordering.tsv: 'Tapachula'
context in metadata.tsv: North America / Mexico / Chiapas / Tapachula

Warning! name not found in color_ordering.tsv: 'Acuña'
context in metadata.tsv: North America / Mexico / Coahuila / Acuña

Warning! name not found in color_ordering.tsv: 'Ciudad Juarez'
context in metadata.tsv: North America / Mexico / Chihuahua / Ciudad Juarez

... (many more warnings) ...

------------------------------------------------------------------------
Part 2
Checking if the same name is repeated in different geographic contexts

Warning! the name 'Aguascalientes' is in more than one geographic context:
North America / Mexico / 'Aguascalientes'
North America / Mexico / Aguascalientes / 'Aguascalientes'
North America / Mexico / Aguascallientes / 'Aguascalientes'

Warning! the name 'Altamira' is in more than one geographic context:
North America / Mexico / Nuevo Leon / 'Altamira'
North America / Mexico / Tamaulipas / 'Altamira'

Warning! the name 'Baja California' is in more than one geographic context:
North America / Mexico / 'Baja California'
North America / Mexico / Chiapas / 'Baja California'

Warning! the name 'Campeche' is in more than one geographic context:
North America / Mexico / 'Campeche'
North America / Mexico / Campeche / 'Campeche'

Warning! the name 'Tecate' is in more than one geographic context:
North America / Mexico / Baja California / 'Tecate'
North America / Mexico / Baja California Sur / 'Tecate'

Warning! the name 'Veracruz' is in more than one geographic context:
North America / Mexico / 'Veracruz'
North America / Mexico / Veracruz / 'Veracruz'

Warning! the name 'Zacatecas' is in more than one geographic context:
North America / Mexico / 'Zacatecas'
North America / Mexico / Zacatecas / 'Zacatecas'

... (many more warnings) ...

------------------------------------------------------------------------
Now run substitute_names.pl.
See https://github.com/luisdelaye/Mexstrain/ for more details.
------------------------------------------------------------------------
```

As mentioned above, the output has two sections. The first part, shows if there is a name in metadata.tsv that is not found in color_ordering.tsv. The warning shows the lacking name together with its geographical context. For instance, the name 'Huixtla' is lacking in color_ordering.tsv and its geographical context whitin metadata.tsv is: 'North America / Mexico / Chiapas / Huixtla'. It is important to understand that whithin metadata.tsv the names of the geographic localities are organized in the following way: 'region / country / division / location'. Not all entries in metadata.tsv have the four categories, some of them have only 'region / country / division ' or fewer. In this case 'Huixtla' is a 'location'.

The second part of the output shows whether there are names repeated within differen geographical contexts. Note that this may not be an error by itself since it is common to find localities sharing the same name. For instance, see the case of 'Campeche' which can refer to the State of Campeche or to the City of Campeche. By the way, the true name of the State of Campeche is: 'Estado Libre y Soberano de Campeche' and the true name of the City of Campeche is: 'San Francisco de Campeche'. But for short, people uses Campeche for both. In cases like this, it is not necesary to change the names in metadata.tsv. 

Now see the case of 'Altamira' (also in the second part of the output) which is in the states of 'Nuevo Leon' and 'Tamaulipas'. This is a problem because each name has to be associated with a single geographic coordinate in lat_longs.tsv. To fix this, we will have to asign different names to the cities of 'Altamira' from 'Nuevo Leon' and from 'Tamaulipas' (for example, we can change the names to: 'Altamira Nuevo Leon' and 'Altamira Tamaulipas'). 

In addition to the above, you may get some surprises. For instance, you may think that it is a mistake that 'Baja California' is a 'location' within the state of 'Chiapas', however it is not. There is in fact a town named 'Baja California' in the State of 'Chiapas' (you can chech this if you google: Baja California Chiapas). Finally see the case of 'Aguascalientes' (the city) wich is in two geographical contexts, in one the State of 'Aguascalientes' is spelled correctly: 'North America / Mexico / Aguascalientes' and in the other it has a typo: 'North America / Mexico / Aguascallientes'. We will see how to fixt the above problems soon.

In addition to the above, compare_names.pl creates a text file named substitute_proposal.tsv that contains three columns separated by tabs:

```
'Asientos'  'North America / Mexico / Aguascalientes / Asientos'  'North America / Mexico / Aguascalientes / Asientos'
'Calvillo'  'North America / Mexico / Aguascalientes / Calvillo'  'North America / Mexico / Aguascalientes / Calvillo'
'Jesus Maria' 'North America / Mexico / Aguascalientes / Jesus Maria' 'North America / Mexico / Aguascalientes / Jesus Maria'
'Pabello de A'  'North America / Mexico / Aguascalientes / Pabello de A'  'North America / Mexico / Aguascalientes / Pabello de A'
'Aguascallientes' 'North America / Mexico / Aguascallientes / Aguascalientes' 'North America / Mexico / Aguascallientes / Aguascalientes'
'Tecate'  'North America / Mexico / Baja California / Tecate' 'North America / Mexico / Baja California / Tecate'
'Los Cabos' 'North America / Mexico / Baja California Sur / Los Cabos'  'North America / Mexico / Baja California Sur / Los Cabos'
'Tecate'  'North America / Mexico / Baja California Sur / Tecate' 'North America / Mexico / Baja California Sur / Tecate'
'CDMX'  'North America / Mexico / CDMX' 'North America / Mexico / CDMX'
'CMX' 'North America / Mexico / CMX'  'North America / Mexico / CMX'
'Calkini' 'North America / Mexico / Campeche / Calkini' 'North America / Mexico / Campeche / Calkini'

...(many more rows)...

```

The first column shows the metadata.tsv name that is lacking in color_ordering.tsv; the second column shows the geographical context of the name; and the third column shows again the geographical context of the name. Each column is separated by a tab. We will use this file to create a new metadata file where all names from geographic localities match those of color_ordering.tsv.

Now that you have an overview of which names do not match (for any of the above and many other reasons), we are going to proceed to fix them. For this, we will use the script substitute_names.pl and some manual curation. You will need to do the following two things: identify which names are simply lacking in color_ordering.tsv and add them to this file (and to lat_longs.tsv, see below); and identify which names do exist in metadata.tsv and color_ordering.tsv (and lat_longs.tsv) but do not match exactly. In this last case, you will need to modify these names. We will show next how to proceed with several examples.

We will begin by adding to color_ordering.tsv (and lat_longs.tsv) those extra names that are found in metadata.tsv. Start by opening the color_ordering.tsv file with a text edditor (like [ATOM](https://atom.io)). Then, take a look at the first part of the output from compare_names.pl. We will start by analysing 'Huixtla'. By looking at color_ordering.tsv you will find that the location of 'Huixtla' is simply lacking. In this case, simply add the name 'Huixtla' to color_ordering.tsv. You will have to add this name in its proper location. For instance, 'Huixtla' is a 'location' whithin de 'division' of 'Chiapas'. Therefore you will have to add the following text to color_ordering.tsv:

```
# Chiapas
location	Huixtla
```

Note that there is a tab between the word 'location' and 'Huixtla'. Because you added a new name to color_ordering.pl, you will have to add this name also to lat_longs.tsv file. Open lat_longs.tsv with a text edditor (like [ATOM](https://atom.io)) and find the correct place (names are in alphabetical order) to add:

```
location	Huixtla	15.13	-92.46
```

Note that the fields are separated by tabs. You can find the coordinates from 'Huixtla' through its [Wikipedia](https://es.wikipedia.org/wiki/Huixtla) page of the city and then clicking on its geographic coordinates: [15°08′00″N 92°28′00″O](https://geohack.toolforge.org/geohack.php?language=es&pagename=Huixtla&params=15.133333333333_N_-92.466666666667_E_type:city). This will take you to a GeoHack page where you can find the coordinates in decimal. You will need to do the same for all names you add to color_ordering.tsv. 

Now we will fix another name. In some occasions the geographic locality is in metadata.tsv and in color_ordering.tsv (and in lat_longs.tsv), but it is written in a different language or the name in metadata.tsv has some typos. Lets take a look at: 'Aguascalientes / Pabello de A'. If you google 'Aguascalientes Pabello de A' you will find that 'Pabello de A' refers to a small city named 'Pabellón de Arteaga' in the State of 'Aguascalientes'. Therefore, you have to substitute 'Pabello de A' by 'Pabellon de Arteaga' in metadata.tsv. To do this, open the file substitute_proposal.tsv with a text editor (like [ATOM](https://atom.io)) and find the row containing 'Pabello de A'. Then substitute 'Pabello de A' by 'Pabellon de Arteaga' in the third column (do not remove the single quotes nor the spaces between the slashes /). Example:

```
'Pabello de A'  'North America / Mexico / Aguascalientes / Pabello de A'  'North America / Mexico / Aguascalientes / Pabellon de Arteaga'
```

The script substitute_names.pl will read this file and will create a new file named outfile.tsv in which the data in the second column will be substituted by the data in the third column. The file outfile.tsv will be identical to metadata.tsv in everithing else. In addition to the above, check if 'Pabellon de Arteaga' is in color_ordering.tsv. If not, you will have to add this name to color_ordering.tsv and lat_longs.tsv as described above. You will do the same for all the names you would like to modify in the metadata. One final thing, you do not need to erase those rows that have the same data in the second and third column, the script will ignore them. 

Now we will review the second part of the output of compare_names.pl. Take a look to the case of 'Altamira'. In Mexico there are two cities with the name 'Altamira', one is in the state of 'Nuevo Leon' and the other is in the state of 'Tamaulipas'. Because of this, we will have to change the name of the cities to differentiate one from the other. One possibility is to name the cities as 'Altamira Nuevo Leon' and 'Atlamira Tamaulipas'. Use the file substitute_proposal.tsv as explained before to change these names. In addition, the names of 'Altamira Nuevo Leon' and 'Altamira Tamaulipas' didn't exist in color_ordering.tsv, so we have to add these cities to this file and to lat_longs.tsv.

Once you have finished adding the lacking names to color_ordering.tsv (and to lat_longs.tsv) and identifying all names that need to be substituted in substitute_proposal.tsv (and if necessary adding these new names to color_ordering.tsv and lat_longs.tsv), the run the script:

```
$ perl substitute_names.pl metadata.tsv substitute_proposal.tsv
```

As mentioned above, this script will output the file: outfile.tsv. This file is an exact copy of metadata.tsv except for those names that were substituted.

Next, run the script curate_names.pl again, but now on outfile.tsv to see if there are no more mismatches (beware that this script will generate a new substitute_proposal.tsv file if there are mismatches):

```
$ perl compare_names.pl color_ordering.tsv outfile.tsv Mexico
```

If there are no more mismatches you should get the following ouptup:

```
------------------------------------------------------------------------
Part 1
Are there names in outfile.tsv lacking in color_ordering.tsv?

------------------------------------------------------------------------
Part 2
Checking if the same name is repeated in different geographic contexts

Warning! the name 'Aguascalientes' is in more than one geographic context:
North America / Mexico / 'Aguascalientes'
North America / Mexico / Aguascalientes / 'Aguascalientes'

Warning! the name 'Baja California' is in more than one geographic context:
North America / Mexico / 'Baja California'
North America / Mexico / Chiapas / 'Baja California'

Warning! the name 'Campeche' is in more than one geographic context:
North America / Mexico / 'Campeche'
North America / Mexico / Campeche / 'Campeche'

Warning! the name 'Chihuahua' is in more than one geographic context:
North America / Mexico / 'Chihuahua'
North America / Mexico / Chihuahua / 'Chihuahua'

Warning! the name 'Durango' is in more than one geographic context:
North America / Mexico / 'Durango'
North America / Mexico / Durango / 'Durango'

Warning! the name 'Merida' is in more than one geographic context:
North America / Mexico / 'Merida'
North America / Mexico / Yucatan / 'Merida'

Warning! the name 'Puebla' is in more than one geographic context:
North America / Mexico / 'Puebla'
North America / Mexico / Puebla / 'Puebla'

Warning! the name 'San Luis Potosi' is in more than one geographic context:
North America / Mexico / 'San Luis Potosi'
North America / Mexico / San Luis Potosi / 'San Luis Potosi'

Warning! the name 'Veracruz' is in more than one geographic context:
North America / Mexico / 'Veracruz'
North America / Mexico / Veracruz / 'Veracruz'

Warning! the name 'Zacatecas' is in more than one geographic context:
North America / Mexico / 'Zacatecas'
North America / Mexico / Zacatecas / 'Zacatecas'
------------------------------------------------------------------------
All names in outfile.tsv have a match in color_ordering.tsv
See https://github.com/luisdelaye/Mexstrain/ for more details.
------------------------------------------------------------------------
```

Note that you got several warnings. But they do not represent errors in outfile.tsv since they correspond to those cities that are named as the states in which they are located. Now change the name of outfile.tsv to:

```
$ mv outfile.tsv metadata.e1.tsv
```

A final tweak to the color_ordering.tsv file is necessary before we go to the next step. Open the color_ordering.tsv file with a text editor (like [ATOM](https://atom.io)) and replace 'Sobral de Monte Agrac O' by 'Sobral de Monte Agraco'. There is a hidden caracter in the last word 'Agrac O' that has to be removed this way. Don't forget to do the same in lat_longs.tsv file. 

Now, copy the color_ordering.tsv file to its directory:

```
cp color_ordering.tsv  /Users/jose/Software/ncov/defaults/
```

### Format the metadata file for Nextstrain

Next, we are going to create the metadata file in the format required for Nextstrain. But first, we need to prepare some files:

```
$ grep '>' sequences.fasta > sequences.fasta.headers.txt
$ grep '>' spikeprot####.fasta > spikeprot####.fasta.headers.txt 
```

Now, run the script format_metadata.pl:

```
$ perl format_metadata.pl metadata.e1.tsv sequences.fasta.headers.txt spikeprot####.fasta.headers.txt
```

You will get the following message:


```
------------------------------------------------------------------------
Number of headers in outfile.tsv: 6912788
------------------------------------------------------------------------
```

This output indicates the number of entries in the new metadata file outfile.tsv. Each entry has its corresponding genome sequence in sequences.fasta.
Next, rename the outfile.tsv:

```
$ mv outfile.tsv metadata.e2.tsv 
```

### Sample sequences for Nextstrain analysis

Nextstrain can handle and display approximately 5000 sequences. But you may have much more. For instance, at the date of writing there are about 15000 sequences from Mexico. Therefore, you need to sample a set of sequences to make the Nextstrain analysis. Here we provide a script to sample at most N genomes from each [Pangolin](https://cov-lineages.org/pangolin.html) lineage per month. Take into account that the script will sample all different available lineages per month. Notice also that this script uses a random number generator to select which genomes to sample. If you use the same number in subsequent runs, you will get the same set of sequences. In our example, we will select at most 5 sequences from each Pangolin lineage per month and use the number 2718 to seed the random number generator.

Before running the script, we have to delete hidden new line characters:

```
$ perl replacemc.pl gisaid_hcov-19_2022_##_##.tsv 
$ mv gisaid_hcov-19_2022_##_##.tsv.e1 gisaid_hcov-19_2022_##_##.e1.tsv 
```

Now, run the script to sample the sequences:

```
$ perl sample_genomes_GISAID.pl gisaid_hcov-19_2022_##_##.e1.tsv 2718 5
```

The script will print to the screen: number of genomes per collection date; number of genomes per Pangolin lineage; number of genomes per clade; and will indicate which genomes were sampled per month per lineage. Next, rename the output:

```
$ mv outfile.tsv gisaid_hcov-19_2022_##_##.e1.sampled.tsv
```

Now, you may whant to sample the genomes downloaded from [Nextstrain global analysis](https://nextstrain.org/ncov/gisaid/global). We can us the same seed to generate random numbers and select at most 5 sequences from each Pangolin lineage per month:

```
$ perl sample_genomes_Nextstrain.pl metadata.e2.tsv nextstrain_ncov_gisaid_global_acknowledgements.tsv 2718 5
$ mv outfile.tsv nextstrain_ncov_global_metadata.sampled.tsv
```

The script will print the same statistics as the previous one. Then, rename the output:

```
$ mv outfile.tsv nextstrain_ncov_gisaid_global.sampled.tsv
```

### Create the sequence and metadata files for Nextstrain analysis

Now we are going to join those genomes sequences that were sampled in the previous steps (from GISAID and Nextstrain) into a single file for Nextstrain analysis. Their associated metadata will be joined too into a single metadata file. This will take a while...

```
$ perl join_sampled_genomes.pl gisaid_hcov-19_2022_##_##.e1.sampled.tsv nextstrain_ncov_gisaid_global.sampled.tsv metadata.e2.tsv sequences.fasta
out: outfile.tsv, outfile.fasta
$ mv outfile.tsv metadata.sampled.tsv
$ mv outfile.fasta sequences.sampled.fasta
```

Now, check wheter the sequences used as external group by Nextstrain are among those that are selected:

```
$ grep 'EPI_ISL_402125' metadata.sampled.tsv 
$ grep 'EPI_ISL_406798' metadata.sampled.tsv 
```

If they are not, includ them with the following script:

```
$ perl add_outgroup.pl metadata.sampled.tsv
$ mv outfile.tsv metadata.sampled.tsv
$ cat sequences.sampled.fasta EPI_ISL_402125.fasta EPI_ISL_406798.fasta > outfile.fasta
$ mv outfile.fasta sequences.sampled.fasta
```

Note that you have to download the sequences EPI_ISL_402125 and EPI_ISL_406798 from [GISAID](https://www.gisaid.org) before concatenating the fasta files. Make sure that the sequence EPI_ISL_402125 contains the FASTA header: >hCoV-19/Wuhan/Hu-1/2019|2019-12-31|2020-01-12; and the sequence EPI_ISL_406798 contains the FASTA header >hCoV-19/Wuhan/WH01/2019|2019-12-26|2020-01-30.

Now, a final tweaks to the metadata and sequences file:

```
$ perl substitute_outgroup_name.pl metadata.sampled.tsv
$ mv outfile metadata.sampled.tsv
$ perl substitute_outgroup_name.pl sequences.sampled.fasta
$ mv outfile sequences.sampled.fasta
```

The above step is required because Nextstrain requires the outgroup sequences to have the names: Wuhan/WH01/2019 and Wuhan/Hu-1/2019. 

Now, check whether there are hiden characters in the sequence file:

```
$ perl replace_mc.pl sequences.sampled.fasta
$ mv sequences.sampled.fasta.e1 sequences.sampled.fasta
```

With this, you have the sequence and the metadata files required to run a Nextstrain analysis:

```
metadata.sampled.tsv
sequences.sampled.fasta
```

Copy these files to the proper location within your Nextstrain local installation (in my case this is):

```
$ cp metadata.sampled.tsv /Users/jose/Software/ncov/data/
$ cp sequences.sampled.fasta /Users/jose/Software/ncov/data/
```

Configure the files builds.yaml, config.yaml, my_auspice_config.json, my_description.md that live within ncov/my_profiles/yourprofileforthisrun/.

But we haven't finished yet. You may want to tell Nextstrain to include in the analysis all the sequences you sampled from the chosen country (in this case Mexico) you which to focus on. For this, you can use the following script:

```
$ perl select_sequences_to_include.pl sequences.sampled.fasta Mexico > add_to_the_include_file.txt
```

Now you simply add the names of the sequences in the file add_to_the_include_file.txt to the file ncov/defaults/include.txt. If you do not add these sequence names to include.txt, Nextstrain will sample from your sample, and this may not be what you want.

Now, run Nextstrain!

```
$ conda activate nextstrain
$ snakemake --cores 16 --profile ./my_profiles/yourprofileforthisrun/ -p
```

### Optional: add columns to the metadata file

If you like, yo can add special columns to the metadata file. Just run:

```
#$ perl add_columns_to_metadata.pl metadata.selected.tsv
#$ mv outfile.tsv metadata.selected.tsv
```
Of course, you have to do the above step just before copying the metadata file to: /Users/jose/Software/ncov/data/.

By default, the script will add a column named VOC where the [Variants of Concern](https://cov-lineages.org/lineage_list.html) will be indicated (Alpha, Beta, Gamma, Delta and Omicron). You can modify the behavior of the script by opening with a text editor (like [ATOM](https://atom.io)) and changing the following section:

```
				#-----------------------------------------------------------------------
				# Here you can modify the options to add the column you want
				# VOC
				if ($a[15] eq 'B.1.1.7'){
					print ROB ("$a[$i]\tAlpha\n");
				} elsif ($a[15] eq 'B.1.351'){
					print ROB ("$a[$i]\tBeta\n");
				} elsif ($a[15] eq 'P.1'){
					print ROB ("$a[$i]\tGamma\n");
				} elsif ($a[15] eq 'B.1.617.2'){
					print ROB ("$a[$i]\tDelta\n");
				} elsif ($a[15] eq 'B.1.1.529' || $a[15] eq 'BA.1' || $a[15] eq 'BA.1.1'
				 			|| $a[15] eq 'BA.2' || $a[15] eq 'BA.3'){
					print ROB ("$a[$i]\tOmicron\n");
				} else {
					print ROB ("$a[$i]\tother\n");
				}
				#-----------------------------------------------------------------------
```

Because the script add_columns_to_metadata.pl adds the column VOC to the metadata file, you will need to modify the my_auspice_config.json file. You can find this file in one of the folders of: ncov/my_profiles/. Open the file and add where properly:

```
    {
      "key": "VOC",
      "title": "Variants of concern",
      "type": "categorical"
    },
```

## Microreact
-----

If you would like to visualize the above sequences in [Microreact](https://microreact.org/showcase) follow these instructions. First, you will need the metadata file created above (metadata.sampled.tsv) and three files from Nextstrain (lat_longs.tsv, aligned.fasta, tree_raw.nwk). Copy the ncov/defaults/lat_longs.tsv file to your working directory and change its name to lat_longs.e1.tsv. Open this file with a text editor and at the bottom of it, add the following:

```
region	Africa	4.070194	21.824559
region	Asia	30.451098	86.654576
region	Europe	49.646237	10.799454
region	North America	28.2367447	-97.738017
region	Oceania	-25.0562891	152.008576
region	South America	-13.083583	-58.470721
```

Now, you have to localize were is the aligned.fasta file in your computer. The aligned.fasta file is the result of running Nextstrain on a given set of sequences. It contains tha alignment of the sequences that will be displyed in auspice. For instance, in the example above, the file in my computer is in: ncov/results/global-mex/aligned.fasta. You can copy this file to your working directory. Once you localized this file, run the following script:

```
$ perl create_microreact.pl lat_longs.e1.tsv aligned.fasta metadata.sampled.tsv Mexico
$ mv outfile.tsv metadata.sampled.mr.tsv 
$ mv outfile_subset.tsv metadata.sampled.mrMexico.tsv
```

The above script will create three files: outfile.tsv, outfile_subset.tsv. The first file contains the table required by Microreact with all the sequences found in metadata.sampled.tsv. The second file contains the table required by Microreact only with the sequences from the country of selection (in this case Mexico). 

Now you can go to [Microreact](https://microreact.org/showcase) and upload the metadata.sampled.mr.tsv and the tree_raw.nwk to visualize your data (Figure 5). You can find the tree_raw.nwk in /ncov/results/global-mex/. The tree_raw.nwk file contains a phylogeny of all the sequences in aligned.fasta.

Note: single quotes "'" in the name of the sequences are transformed to underscores _ in the names of the sequences in the tree. For instance, the sequence name in metadata: Lu'an/5073Y is transformed to Lu_an/5073Y in tree_raw.nwk. If you have sequence names with single quotes, simply open the outfile.tsv with a text editor and remplace the single quote by an underscore. In the example above, just open the outfile.tsv file with a text editor and rename the sequence Lu'an/5073Y to Lu_an/5073Y. Otherwise Microreact will not work.

<p align="center">
  <img width="707.5" height="371.5" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure-5-Mexstrain.png">
</p>
Figure 5. Microreact visualization of sequences.


If you would like to visualize in [Microreact](https://microreact.org/showcase) only those sequences from the selected country (Mexico) altogether with a phylogenetic tree, follow the next instructions. You will need to run the script:

```
$ perl exstract_secs.pl metadata.sampled.mrMexico.tsv aligned.fasta
$ mv outfile metadata.sampled.mrMexico.fasta
```

This will create a file named outfile that contains the sequences whose ids are found in outfile_subset.tsv. This is, all the sequences from Mexico originaly found in metadata.sampled.tsv. Rename this file to metadata.sampled.mrMexico.fasta. Then run [iqtree](http://www.iqtree.org) to infer a phylogenetic tree:

```
$ iqtree -s metadata.sampled.mrMexico.fasta -m GTR+I+G
```

Now add the extension nwk to the phylogeny file and upload the phylogeny and the metadata.sampled.mrMexico.tsv files to [Microreact](https://microreact.org/showcase).

### Display all sequences from a country in Microreact

You may want to display all sequences from a country in Microreact. For this, you will need the metadata.e2.tsv file and the following script:

```
$ perl create_microreact_all.pl lat_longs.e1.tsv metadata.e2.tsv Mexico
$ mv outfile_all.tsv metadata.mrMexico.tsv
```

The above script will create the file outfile_all.tsv. Simply upload this (metadata.mrMexico.tsv) file to [Microreact](https://microreact.org/showcase). Because the number of genomes is usually very high, it is not practical to do a phylogenetic analysis.


