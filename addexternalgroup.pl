#!/usr/bin/perl

# This script add the external group to the metadata file for Nextstrain analysis

# use
# perl addexternalgroup.pl metadata.selected.tsv
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

my $file   = $ARGV[0]; # metadata.selected.tsv file
system ("cp $file outfile.tsv");
#-------------------------------------------------------------------------------
# Add external groups
open (ROB, ">>outfile.tsv") or die ("Can't open outfile.tsv\n");
print ROB ("hCoV-19/Wuhan/Hu-1/2019|2019-12-31|2020-01-12\tEPI_ISL_402125\t2019-12-31\tAsia\tChina\tHubei\tWuhan\t29903\tHuman\t?\t?\t19A\tB\t?\tNational Institute for Communicable Disease Control and Prevention (ICDC) Chinese Center for Disease Control and Prevention (China CDC)\tNational Institute for Communicable Disease Control and Prevention (ICDC) Chinese Center for Disease Control and Prevention China\tZhang et al\n");
print ROB ("hCoV-19/Wuhan/WH01/2019|2019-12-26|2020-01-30\tEPI_ISL_406798\t2019-12-26\tAsia\tChina\tHubei\tWuhan\t29866\tHuman\t44\tMale\t19A\tB\t?\tGeneral Hospital of Central Theater Command of People's Liberation Army of China\tBGI & Institute of Microbiology, Chinese Academy of Sciences & Shandong First Medical University & Shandong Academy of Medical Sciences & General Hospital of Central Theater Command of People's Liberation Army of China\tWeijun Chen et al\n");
close (ROB);
