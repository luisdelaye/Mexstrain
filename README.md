# Mexstrain
-----------

Perl scripts to manipulate data derived from GISAID and Nextstrain.

Last update: January 10, 2022.

The scripts in this repository facilitate the manipulation of data (metadata and fasta sequences) downloaded from GISAID to make a Nextstrain analysis. In particular, the scripts allow to subsample sequences from Nextstrain and GISAID to make a Nextstrain analysis focused in a given Country (Figure 1). For instance, we used these scripts to create [Mexstrain](http://www.ira.cinvestav.mx/ncov.evol.mex.aspx).

<p align="center">
  <img width="720" height="405" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure-1-Mexstrain.jpeg">
</p>
Figure 1. Mexstrain allows to combine information from Nextstrain and GISAID to make a phylodynamic analysis focused on a single country.


### Collect data

First collect the data. Go to the latest global analysis provided by [Nextstrain](https://nextstrain.org/ncov/global), scroll to the bottom of the page, select 'DOWNLOAD DATA' and then 'ACKNOWLEDGEMENTS (TSV)'. You will get a file named nextstrain_ncov_gisaid_global_acknowledgements.tsv. 

Next, go to [GISAID](https://www.gisaid.org) and download all FASTA sequences (sequences.fasta) and asociated metadata (metadata.tsv). You will find these files in 'Downloads -> Downoads packages'. Also download Spike protein sequences in FASTA format (spikeprot####.fasta). You can find these sequences in 'Downloads -> Alignment and proteins'. In Figure 2 you can see where to find these files in GISAID. Don't forget to decompress these files.

<p align="center">
  <img width="735.75" height="607.5" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure-2-Mexstrain.png">
</p>
<p style='text-align: right;'> Figure 2. Location of the files sequence.fasta, metadata.tsv and spikeprot####.fasta in GISAID. </p>


Also in [GISAID](https://www.gisaid.org), download all the 'Patient status metadata' associated to the genome sequences from the country (or any other geographical region) on which you would like to focus your Nextstrain analysis. In this case, we will download the metadata from all complete and high coverage sequences from Mexico (gisaid_hcov-19_2022\_##\_##.tsv). You can find this information in 'Search -> Location -> North America -> Mexico' and by clicking in the boxes 'complete' and 'high coverage' and when asked, download the 'Patient status metadata' (Figure 3). 

<p align="center">
  <img width="736.5" height="596.25" src="https://github.com/luisdelaye/Mexstrain/blob/main/Figure-3-Mexstrain.png">
</p>
<p style='text-align: right;'> Figure 3. Download all the metadata asociated to the country on which you would like to focus your Nextstrain analysis. </p>


Because you can download a maximum of 10,000 records each time, you may need to download several files, one for each state/division. In the case of Mexico, we need to download one file for each one of the states (Aguascalientes, Baja California, Baja California Sur, etc.) If you like, you can add the name of the state to each of the files (avoid spaces or accents in the name of the files), for example:

```
$ mv gisaid_hcov-19_2022_01_11_01.tsv gisaid_hcov-19_2022_01_11_01_Aguascalientes.tsv
```

Just keep the first part of the filename 'gisaid_hcov-19_2022_' and the extension 'tsv'. Next, you will need to run the script:

```
$ perl concatenatetsvfiles.pl gisaid_hcov-19_2022_
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

Now comes the toughest part: to assure that the names of the geographic localities are spelled the same in all files. First, a bit of background. We will asume that you have a local Nextstrain installation. Nextstrain store the name of geographic localities in two files: color_ordering.tsv and lat_longs.tsv. These files live in: ncov/defaults/ wihtin your Nextstrain installation directory. The first file (color_ordering.tsv) is used by Nextstrain to know if a given locality is a 'location', 'division', 'country' or a 'region'; the second file (lat_longs.tsv) keeps the geographic coordinates of all the places found in color_ordering.tsv. These files were prepared by the people from Nextstrain and share the same grographic localities. 

The names of the geographic localities in color_ordering.tsv and lat_longs.tsv have to match those in metadata.tsv. However, this is not always the case because the names in metadata.tsv are captured by many different people around the world and sometimes these people introduce typos. In addition, the names in metadata.tsv can be in other lenguages and most names (but not all!) in color_ordering.tsv are in English. Last but not least, there can be geographic localities in metadata.tsv that are lacking in color_ordering.tsv and lat_longs.tsv. These lacking localities have to be added to color_ordering.tsv and lat_longs.tsv.

To fix the above problem, we can do the following: i) change the names of the geographic localities in the metadata.tsv file so they match those of the color_ordering.tsv and lat_longs.tsv files; ii) change the names in color_ordering.tsv and lat_longs.tsv files so they match those in metadata.tsv; and/or iii) add new names to color_ordering.tsv and lat_longs.tsv files. At the end, keep in mind that the names have to be spelled correctly. We also suggest that the names are written without accents or other characters not found in English. Remember also that any given geographic locality (whether it is a 'location', 'division', 'country' or a 'region') has to be identified with only one name.

The first thing to do is to check whether the names of the geographic localities in metadata.tsv are also found in color_ordering.tsv. We will do this specifically for the names of the country on which you would like to focus your Nextstrain analysis (in this case: Mexico). For this we use the script compare_names.pl. We recommend you to make security copies of the original color_ordering.tsv and lat_longs.tsv files (in case you would like to recover the original files) and then make a copy of color_ordering.tsv to your working directory. Then run the script:

```
$ perl compare_names.pl color_ordering.tsv metadata.tsv Mexico
```

This script will check if the names of the geographical localities in metadata.tsv are found in color_ordering.tsv. If a name is not found, it will print a warning message to the screen. This script will also check whether the same name is repeated whithin different geographic contexts (note that this may not be an error by itself). In our example data, the first time you run the curate_names.pl script you will get the following output:

```

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

... (many more warnings) ...

------------------------------------------------------------------------
Checking if the same name is repeated in different geographic contexts

Warning! the name Aguascalientes is in more than one geographic context:
North America / Mexico
North America / Mexico / Aguascalientes
North America / Mexico / Aguascallientes

Warning! the name Altamira is in more than one geographic context:
North America / Mexico / Nuevo Leon
North America / Mexico / Tamaulipas

Warning! the name Baja California is in more than one geographic context:
North America / Mexico
North America / Mexico / Chiapas

Warning! the name Campeche is in more than one geographic context:
North America / Mexico
North America / Mexico / Campeche

... (many more warnings) ...

------------------------------------------------------------------------
The following names don't match any name in the color_ordering.tsv file:

'Aguascalientes / Pabello de A'
'Chihuahua / Juarez'
'Coahuila / Acuña'
'Coahuila / Castaños'
'Hidalgo / Cardonal Hgo'
'Hidalgo / El Arenal'
'Jalisco / Guadalajara Tetlan'
'Jalisco / Tlajomulco De Zuñiga'
'Jalisco / Vallarta'
'Mexico / Aguascallientes'
'Mexico / CDMX'
'Mexico / CMX'
'Mexico / Ciudad de Mexico'
'Mexico / Coahuila de Zaragoza'

... (many more names) ...

'Zacatecas / Rio Grande'
'Zacatecas / Sombrerete'

------------------------------------------------------------------------
Now run substitute_names.pl.
See https://github.com/luisdelaye/Mexstrain/ for more details.
------------------------------------------------------------------------
```

The output has three sections. The first part, simply shows if there is a name in metadata.tsv that is not found in color_ordering.tsv. The warning shows the lacking name all together with its geographical context. For instance, the name 'Huixtla' is lacking in color_ordering.tsv and its geographical context is: 'North America / Mexico / Chiapas / Huixtla' whitin metadata.tsv. It is important to understand that whithin metadata.tsv the names of the geographic localities are organized in the following way: 'region / country / division / location'. In this case 'Huixtla' is a 'location'.

The next part of the output shows whether there are names repeated within differen geographical contexts. Note that this may not be an error by itself since it is common to find cities sharing the same name. For instance, see the case of 'Campeche' which can refer to the State of Campeche or to the City of Campeche. By the way, the true name of the State of Campeche is: 'Estado Libre y Soberano de Campeche' and the true name of the City of Campeche is: 'San Francisco de Campeche'. But for short, the people uses Campeche for both. In this case it is not necesary to change the names in metadata.tsv nor color_ordering.tsv and lat_longs.tsv. But now see the case of Altamira which is in the States of Nuevo Leon and Tamaulipas. This is a problem because each name has to be associated with a single geographic coordinate in lat_longs.tsv. In addition, you may get some surprises. For instance, there is a town named 'Baja California' in the State of Chiapas (you can chech this if you google: Baja California Chiapas). Finally see the case of Aguascalientes (the City) wich is in two geographical context, in one the State of Aguascalientes is spelled correctly: 'North America / Mexico / Aguascalientes' and in the other it has a typo: 'North America / Mexico / Aguascallientes'. We will see how to fixt the above problems soon.

The last part of the output shows a summary ot the names in metadata.tsv not found in color_ordering.tsv in its most immediate geographical context. 

Now that you have an overview of which names do not match (for any of the above reasons), we are going to proceed to fix them. For this, we will use the script substitute_names.pl and some manual curation. You will need to do the following two things: identify which names are simply lacking in color_ordering.tsv and add them; and identify which names do exist in metadata.tsv but do not match in color_ordering.tsv and modify them. We will show next how to proceed.

Open the color_ordering.tsv file with a text edditor (like [ATOM](https://atom.io)). Next, take a look at the last part of the output of compare_names.pl (the summary section). We will fix each one of the names in the list one by one. Lets start with the first one: 'Pabello de A'. If you google 'Aguascalientes Pabello de A' you will find that 'Pabello de A' refers to a small city named 'Pabellón de Arteaga' in the State of Aguascalientes. To fix this name, you need to create a text file named 'substitute.tsv'. This file will have three columns separated by tabs. In the first column, write the most immediante, superior geographic category in which the locality with the wrong name is located (i.e. in this case is Aguascalientes). In the second column, write the name to be substituted (in this case 'Pabello de A'). And in the third column write the name that is going to substitute the previous name (in this case 'Pabellon de Arteaga'). An example of this file is shown below:

```
Aguascalientes	Pabello de A	Pabellon de Arteaga
```

The script substitute_names.pl will read this file and will create a new file named outfile.tsv where 'Aguascalientes / Pabello de A' will be substitute by 'aguascalientes / pabellon de arteaga'. Don't bother about lowercase names, this will be fixed later. You can add as many rows a you like to substitute names in metadata.tsv. These names will appear substituted in outfile.tsv which is an exact copy of metadata.tsv in everithing else. A larger version of substitute.tsv is shown next:

```
Aguascalientes	Pabello de A	Pabellon de Arteaga
Coahuila	Acu.{2}a	Acuna
Coahuila	Castaños	Castanos
Jalisco	Vallarta	Puerto Vallarta
Mexico	Aguascallientes	Aguascalientes
Yucatan	M.{2}rida	Merida
Mexico	Yucatán	Yucatan
Nuevo Leon	Altamira	Altamira Nuevo Leon
Tamaulipas	Altamira	Altamira Tamaulipas
```

As you can see, we substituted 'Vallarta' by 'Puerto Vallarta' and 'Aguascallientes' by 'Aguascalientes' (among others). It is worth mentioning the case of 'Yucatan'. In the color_ordering.tsv file the State is written as 'Yucatan' (without accent) however in metadata.tsv is written as 'Yucatán' (with accent). To substitute 'Yucatán' by 'Yucatan', we can use Perl [regular expressions](https://perldoc.perl.org/perlre). To match an accented vowel with Perl regular expressions do it like this: Yucat.{2}n. The regular expression .{2} tels Perl to match any two characters; this matches the vowel á (because it is composed by the letter a + the accent). As a result 'Yucatán' will be substituted by 'Yucatan'. We also used regular expressions to substitute 'Acuña' by 'Acuna' (to match the letter ñ we also need tell Perl to match any two characters). Perl regular expressions are extremely powerfull, we recommend you to take a look at them.

Now take a look also to the case of Altamira. In Mexico there are two cities whit the name Altamira, one is in the state of Nuevo Leon and the other in Tamaulipas. As you remember, this was indicated in the second part of the compare_names.pl output (see above). Therefore we will tell substitute_names.pl to substitute 'Nuevo Leon / Altamira' by 'Nuevo Leon / Altamira Nuevo Leon' and the other by 'Tamaulipas / Altamira Tamaulipas'. In this case, the cities of 'Altamira Nuevo Leon' and 'Altamira Tamaulipas' didn't exist in color_ordering.tsv, so we have to add these cities to this file and also to lat_longs.tsv (see below).

Now take a look at the second line in the summary section of the output of compare_names.pl. By looking a color_ordering.tsv you will find that the City of Juarez (in the State of Chihuahua) is simply lacking. The official name of the city is 'Ciudad Juárez' and you will not find it (nor the name without accent: 'Ciudad Juarez') in color_ordering.tsv. In this case, simply add the name 'Ciudad Juarez' to color_ordering.tsv. You will have to add this name in its proper location. For instance, 'Ciudad Juarez' is a 'location' whithin de 'division' of 'Chihuahua'. Therefore you will have to add the following text to color_ordering.tsv:

```
# Chihuahua
location	Ciudad Juarez
```

Because you added a new name to color_ordering.pl, you will have to add this name also to lat_longs.tsv file. Open lat_longs.tsv with a text edditor (like [ATOM](https://atom.io)) and find the correct place to add:

```
location	Ciudad Juarez	31.73	-106.48
```

You can find the coordinates from Ciudad Juarez through the Wikipedia page of the city and then clicking on its geographic coordinates: 31°44′18.89″N 106°29′13.25″W. This will take you to a GeoHack page where you can find the coordinates in decimal. You will need to do the same for all names you add to color_ordering.tsv. As mentioned above, do the same for 'Altamira Nuevo Leon' and 'Altamira Tamaulipas'.

You will find that there are many reasons why the names in metadata.tsv do not match those of color_ordering.tsv and lat_longs.tsv. For instance, in metatada.tsv the name 'State of Mexico' is written in English and in color_ordering.tsv is in Spanish: 'Estado de Mexico'. In other occasions the name in one of the files is the full name of the place. This is the case of 'Coahuila de Zaragoza' which is written simply as 'Coahuila' in color_ordering.tsv. In addition, some names are written with accents in metadata.tsv (like 'Yucatán') and without accents in color_ordering.tsv. Finally (and very often), some names are simply missing in color_ordering.tsv, like 'Zapopan'. In any case, you will have to study each one of the and decide the best way to fix the problem. 

Once you have finished adding the lacking names to color_ordering.tsv (and names and coordinates lat_longs.tsv) and identifying all names that need to be substituted in substitute.tsv, run the script:

```
$ perl substitute_names.pl color_ordering.tsv metadata.tsv Mexico substitute.tsv
```




Next, run the script again to see if there are no more mismatches:

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

A final tweak to the color_ordering.tsv file is necessary before we go to the next step. Open the color_ordering.tsv file with a text editor (like [ATOM](https://atom.io)) and replace 'Sobral de Monte Agrac O' by 'Sobral de Monte Agraco'. There is a hidden caracter in the last word 'Agrac O' that has to be removed this way. 

### Format the metadata file for Nextstrain

Next, we are going to create the metadata file in the format required for Nextstrain. But first, we need to prepare some files:

```
$ grep '>' sequences.fasta > sequences.fasta.headers.txt
$ grep '>' spikeprot####.fasta > spikeprot####.fasta.headers.txt 
```

Now, run the script format_metadata.pl:

```
$ perl format_metadata.pl metadata.e1.tsv sequences.fasta.headers.txt spikeprot####.fasta.headers.txt color_ordering.tsv
```

It is possible that you get the following warning message:


```
Warning! misspelled names:
Category	(original name)	(misspelled name)
Location	(Šumavské Hoštice)	(?umavské Hoštice)

There are misspelled names
You have to open create_metadata.pl and code Perl to fix the problem
Go to the bottom of the file and where indicated, code:

  } elsif ($newword =~ /misspelled name/){
    $newword = 'original name';

You may need to use pattern matching to contend with unusual characters
Press enter to continue
```

If you get this message, you will have to open the format_metadata.pl file and go to the bottom to find the place where you have to code for the original name. For instance, in the example above you would have to code the following to fix the name:


```
  } elsif ($newword =~ /^.+umavsk.+ Ho.+tice$/){
   $newword = 'Šumavské Hoštice';
```

Notice that I used pattern matching to match the misspelled name: '?umavské Hoštice'.

If you don't get the warning message, simply rename the outfile.tsv


```
$ mv outfile.tsv metadata.e2.tsv 
```

### Sample sequences for Nextstrain analysis

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
$ perl selectgenomesN.pl metadata.e2.tsv nextstrain_ncov_gisaid_global_acknowledgements.tsv 31416 5
$ mv outfile.tsv nextstrain_ncov_global_metadata.selected.tsv
```

### Create the sequence and metadata files for Nextstrain analysis

Now we are going to join selected genome sequences (and their associated metadata) from GISAID and Nextstrain into a file (each) for Nextstrain analysis. This will take a while...

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

Because the script addcolumns.pl adds the columns VOI and VOC to the metadata file, you will need to modify the my_auspice_config.json file. You can find this file in one of the folders of: ncov/my_profiles/. Open the file and add where properly:

```
    {
      "key": "VOI",
      "title": "Variants of interest",
      "type": "categorical"
    },
    {
      "key": "VOC",
      "title": "Variants of concern",
      "type": "categorical"
    },
```

But we haven't finished yet. You may want to tell Nextstrain to include in the analysis all the sequences from the country (in this case Mexico) you which to focus on. For this you can use the following script:

```
$ perl addtoinclude.pl sequences.selected.fasta Mexico > add_toinclude.txt
```

Now you will simply add the names of the sequences in the file add_toinclude.txt to the file ncov/defaults/include.txt.

Now, run Nextstrain!

## Microreact
-----

If you would like to visualize the above sequences in [Microreact](https://microreact.org/showcase) follow these instructions. First, you will need the metadata file created above (sequences.selected.tsv) and two files from Nextstrain (lat_longs.tsv, aligned.fasta). Copy the ncov/defaults/lat_longs.tsv file to your working directory and change its name to lat_longs.e1.tsv. Open this file with a text editor and at the bottom of it, add the following:

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
$ perl createmicroreact.pl lat_longs.e1.tsv aligned.fasta metadata.selected.tsv Mexico
```

The above script will create three files: outfile.tsv, outfile_subset.tsv, prunetree.py. The first file contains the table required by Microreact with all the sequences found in metadata.selected.tsv. The second file contains the table required by Microreact only with the sequences from the country of selection (in this case Mexico). The third file is a python program that uses [ete3](http://etetoolkit.org) to prune a tree to leave only sequences from Mexico. You can find the tree to prune in the same directory as the aligned.fasta file under the name of tree_raw.nwk. At this point, we are not going to prune the tree.

Now you can go to [Microreact](https://microreact.org/showcase) and upload the outfile.tsv and the tree_raw.nwk to visualize your data. Note: in our example, there is a sequence in outfile.tsv with the name: Lu'an/5073Y. The same sequence in the tree_raw.nwk is named as Lu_an/5073Y. Just open the outfile.tsv file with a text editor and rename the sequence Lu'an/5073Y as Lu_an/5073Y. Otherwise Microreact will not work.

If you would like to visualize in [Microreact](https://microreact.org/showcase) only those sequences from the selected country (Mexico), follow the next instructions. You will need to run the script:

```
$ perl exstractsecs.pl outfile_subset.tsv alignment.fasta
```

This will create a file named outfile that contains the sequences whose ids are found in outfile_subset.tsv. This is, all the sequences from Mexico originaly found in metadata.selected.tsv. Rename this file to outfile_subset.fasta. Then run [iqtree](http://www.iqtree.org) to infer a phylogenetic tree:

```
$ iqtree -s outfile_subset.fasta -m GTR+I+G
```

Now add the extension nwk to the phylogeny file and upload the phylogeny and the outfile_subset.tsv files to [Microreact](https://microreact.org/showcase).

### Display all sequences from a country in Microreact

You may want to display all sequences from a country in Microreact. For this, you will need the metadata.e2.tsv file and the following script:

```
$ perl createmicroreactall.pl lat_longs.e1.tsv metadata.e2.tsv Mexico
```

The above script will create the file outfile_all.tsv. Simply upload this file to [Microreact](https://microreact.org/showcase). Because the number of genomes is usually very high, it is not practical to do a phylogenetic analysis.


