# Mexstrain
Perl scripts to manipulate data derived from GISAID and Nextstrain.

The scripts in this repository facilitate the manipulation of data (metadata and fasta sequences) downloaded from GISAID to update a Nextstrain analysis. In Figure 1 we summaryze the sequential use of the scripts. 

First collect the data. Go to the latest global analysis provided by Nextstrain (https://nextstrain.org/ncov/global), scroll to the bottom of the page, select 'DOWNLOAD DATA' and then 'DOWNLOAD ALL METADATA (TSV)'. Next, go to GISAID (https://www.gisaid.org) and download all fasta sequences and metadata already formatted for Nextstrain analysis (you will find these files in 'Downloads'). Finally, also in GISAID go to 'Search' and download all the sequences you would like to add to the latest Nextstrain analysis.

Suppose that you downloaded the following files:

nextstrain_ncov_global_metadata.tsv # latest global analysis provided by Nextrain

sequences.fasta # fasta genome sequences from GISAID formated for Nextstrain

metadata.tsv # metadata from GISAID formatted for Nextstrain

gisaid_hcov-19_Mex.fasta # selected fasta genome sequences downloaded from GISAID

Use the scripts as follow:

Delete hiden newline characters

$ perl replacemc.pl gisaid_hcov-19_Mex.fasta

$ mv gisaid_hcov-19_Mex.fasta.e1 gisaid_hcov-19_Mex.e1.fasta

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

$ perl createfiles.pl ncov_Mex_IDs.txt gisaid_hcov-19_Mex.e1.fasta sequences.fasta metadata.tsv 

Concatenate the files 

$ cat nextstrain_ncov_global_metadata.f.tsv outfile.txt > nextstrain_ncov_global_metadata.fc.tsv

$ cat nextstrain_ncov_global_metadata.fasta outfile.fasta > nextstrain_ncov_global_metadata.fc.fasta

Move the files nextstrain_ncov_global_metadata.fc.tsv and nextstrain_ncov_global_metadata.fc.fasta to the Nextstrain data/ directory, modify the config.yaml file and run Nextstrain!

Finally, if you would like to be sure that a given set of sequences are included in your Nextstrain analysis, you can use the following script

$ perl toinclude.pl nextstrain_ncov_global_metadata.fc.fasta Mexico > add_to_include.txt

Just add the IDs in add_to_include.txt to the file defaults/include.txt in you local Nextstrain installation. 


