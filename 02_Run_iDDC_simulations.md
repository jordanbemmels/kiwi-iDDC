# Running iDDC model simulations

This document describes how to compile directories for each of the iDDC models, and how to run the simulations.

Most of the files are already partly compiled and located in the [model_scripts](https://github.com/jordanbemmels/kiwi-iDDC/tree/main/model_scripts) directory, but some additional organization is needed. In particular, users will need to add executable files for published simulation software, and generic iDDC scripts that have previously been published, as described below.

## Inspecting contents of model directories

There are input scripts for running iDDC simulations for each of the kiwi models discussed in the manuscript, located here:

```
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G
kiwi-iDDC/model_scripts/mantelliABC_v6_model_H
[...]
```

Each directory contains all of the model-specific scripts needed to run simulations. However, some additional generic code and software will need to be added as described below before the simulation can actually be run.

The contents provided in the model directories (here, an example is shown for Model G) are as follows:

```
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/mantelli.est # input file for ABCtoolbox describing the priors
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/mantelliABC_v6_model_G.input # input file for ABCtoolbox describing the simulation files and software, and calculation of summary statistics
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/splatche3input # directory containing input files for running the SPLATCHE3 simulation software
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/splatche3input/Arrival_cell.col # locations of demes for which to check colonization times during the demographic simulation
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/splatche3input/GenSamples.sam # sampling sites and population sizes for which to simulate genetic data
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/splatche3input/dens_init_LIG.txt # densities of initial demes
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/splatche3input/dynamic_K_model_G.txt # describes which veg2K files are used for which generations in the demographic simulation
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/splatche3input/genetic_data_SNP.par # parameters for simulating SNPs
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/splatche3input/oriworld_model_G.asc # map file used in conjunction with dynamic_K and veg2K files to describe carrying capacity in different time periods
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/splatche3input/settings_model_G.asc # settings for the SPLATCHE3 simulation
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/splatche3input/veg2K_model_G_envXXX.txt # multiple files describing carrying capacities in the oriworld file that should be applied to environment XXX, with as many different veg2K files as there are time periods for each model
```

## Compiling a generic *calSumStat* directory

A directory named *calSumStat* is required, and is generic (i.e., identical) for all models. This directory contains the scripts necessary for converting raw SNP genotypes simulated by SPLATCHE3 into genetic summary statistics.

A complete version of *calSumStat* is not provided here, because it will contain executable scripts from published software and publicly-available iDDC scripts written by other authors that are not my own intellectual property. Thus, it will be necessary to gather a few scripts from other sources.

A complete version of a *calSamStat* directory with scripts useful for iDDC modelling has previously been published as part of [X-ORIGIN](https://github.com/KnowlesLab/X-ORGIN) software ([He et al. 2017 Mol Ecol](https://doi.org/10.1111/mec.14380)). If you use these scripts, please cite the following:

*1. He, Q, JR Prado, and LL Knowles. 2017. Inferring the geographic origin of a range expansion: Latitudinal and longitudinal coordinates inferred from genomic data in an ABC framework with the program X-ORIGIN. Mol Ecol, **26**: 6908-6920.*</br>
*2. He, Q, DL Edwards, and LL Knowles. 2013. Integrative testing of how environments from the past to the present shape genetic structure across landscapes. Evolution, **67**: 3386-3402.*

And if you use the ```arlsumstat``` executable distributed with X-ORIGIN, please cite Arlequin:

*3. Excoffier, L, and HEL Lischer. 2010. Arlequin suite ver 3.5: a new series of programs to perform population genetic analyses under Linux and Windows. Mol Ecol Res, **10**: 564-567.*

(Note that the kiwi iDDC project does not actually make use of the full X-ORIGIN pipeline. X-ORIGIN is a very particulary type of iDDC modelling. The goal of X-ORIGIN is to estimate the latitude and longitude of range expansions, whereas the goal of the kiwi iDDC project was different. We are only downloading files from the X-ORIGIN pipeline because this is where necessary scripts used in the kiwi project have previously been published by other authors, and are publicly accessible. Note that X-ORIGIN scripts are set up to generate additional summary statistics not mentioned in the manuscript: K (number of alleles), and psi (directionality index). Both of these statistics are calculated by the scripts but were not used in the kiwi iDDC project. K was not used because it was highly redundant with expected heterozygosity. Psi was not used because the kiwi models do not test range expansion from a single refugium. It is not harmful to calculate these statistics for kiwi and they will be excluded from the ABC procedure in subsequent steps.)

Begin by downloading X-ORIGIN v1.0 (XOrigin_v1) from [https://github.com/KnowlesLab/X-ORGIN/releases](https://github.com/KnowlesLab/X-ORGIN/releases). Extract and copy ```./X-ORGIN/example/calSumStat``` to a convenient working directory (adjust relative paths as necessary):

```
cd ./
cp -r X-ORGIN/example/calSumStat kiwi-iDDC/workingDir_compileCalSumStat
cd kiwi-iDDC/workingDir_compileCalSumStat
```

The directory ```workingDir_compileCalSumStat``` contains the following files:

```
arl_run.ars # input file for Arlequin
arlsumstat # executable file for Arlequin
calPsi.r # calculates directionality index (psi statistic)
calSumStat.py # controls the execution of Arlequin
empiricalSS.obs # observed summary statistics from the empirical dataset
re_functions_resistance.r # additional functions loaded by calPsi.r
ssdefs.txt # input file for Arlequin
```

We do not need to modify *calPsi.r*, *calSumStat.py*, or *re_functions_resistance.r*. You may need to replace the default *arlsumstat* executable with a version that works on your own system (can be downloaded from the [Arlequin web page](http://cmpg.unibe.ch/software/arlequin35/), if the downloaded one does not work. The remaining three files (*arl_run.ars*, *empiricalSS.obs*, and *ssdefs.txt*) are specific to the example downloaded from the X-ORIGIN repository and will not work with the kiwi iDDC models. These three files need to be replaced with updated versions specific to the kiwi iDDC project, which are located in [kiwi-iDDC/model_scripts/](https://github.com/jordanbemmels/kiwi-iDDC/tree/main/model_scripts/calSumStat_kiwi_replacementFiles).

```
cd kiwi-iDDC/workingDir_compileCalSumStat
rm arl_run.ars
rm empiricalSS.obs
rm ssdefs.txt
cp ../model_scripts/calSumStat_kiwi_replacementFiles/* ./
```

Now, ```kiwi-iDDC/workingDir_compileCalSumStat``` has all the files updated for the kiwi project, and is ready to be used with any of the kiwi iDDC models. Move a copy (renaming it as "calSumStat") to each of the model directories.

```
cd kiwi-iDDC
cp -r workingDir_compileCalSumStat model_scripts/mantelliABC_v6_model_G/calSumStat
cp -r workingDir_compileCalSumStat model_scripts/mantelliABC_v6_model_H/calSumStat
[...]
cp -r workingDir_compileCalSumStat model_scripts/mantelliABC_v6_model_yR/calSumStat
```

## Adding simulation software executable files

Executable files for the simulation software need to be added to each of the model directories (e.g., *kiwi-iDDC/model_scripts/mantelliABC_v6_model_G*). The Arlequin executable ```arlsumstat``` has already been added to the ```calSumStat``` directory above. We need to add two additional exeutables:

1. An executable for SPLATCHE3 named ```SPLATCHE3-Linux_64b``` is placed within the ```splatche3input``` subdirectory for each model. The ```SPLATCHE3-Linux_64b``` executable can be downloaded for Linux from [https://www.splatche.com/splatche3](https://www.splatche.com/splatche3) (console version). If you use this executable, be sure to cite:

*Currat, M, M Arenas, CS Quilodràn, L Excoffier, and N Ray. 2019. SPLATCHE3: simulation of serial genetic data under spatially explicit evolutionary scenarios including long-distance dispersal. Bioinformatics: **35**: 4480-4483.*

An example where to place the executable for Model G is as follows:

```
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/splatche3input/SPLATCHE3-Linux_64b
```

2. An executable for ABCtoolbox named ```ABCsampler``` is placed within the main directory for each model. The ```ABCtoolbox``` executable can be downloaded for Linux from [http://cmpg.unibe.ch/software/ABCtoolbox](http://cmpg.unibe.ch/software/ABCtoolbox). If you use this executable, be sure to cite:

*Wegmann, D, C Leuenberger, S Neuenschwander, and L Excoffier. 2010. ABCtoolbox: a versatile toolkit for approximate Bayesian computations. BMC Bioinformatics, **11**: 116.*

An example where to place the executable for Model G is as follows:

```
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/ABCsampler
```

## Confirming model directories are ready to run simulations

One the ```calSumStat``` directory and the software executables have been added to each model directory, check that all files are present and in their proper locations. An example to check whether all files are in their correct locations for Model G is as follows:

```
kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/
find . | sort -n
```

If everything is set up correctly, the result of that command should be:

```
.
./ABCsampler
./calSumStat
./calSumStat/arl_run.ars
./calSumStat/arlsumstat
./calSumStat/calPsi.r
./calSumStat/calSumStat.py
./calSumStat/empiricalSS.obs
./calSumStat/re_functions_resistance.r
./calSumStat/ssdefs.txt
./mantelli.est
./mantelliABC_v6_model_G.input
./splatche3input
./splatche3input/Arrival_cell.col
./splatche3input/GenSamples.sam
./splatche3input/SPLATCHE3-Linux-64b
./splatche3input/dens_init_LIG.txt
./splatche3input/dynamic_K_model_G.txt
./splatche3input/genetic_data_SNP.par
./splatche3input/oriworld_model_G.asc
./splatche3input/settings_model_G.txt
./splatche3input/veg2K_model_G_env1_LIG.txt
./splatche3input/veg2K_model_G_env2_postLIG.txt
./splatche3input/veg2K_model_G_env3_preLGM.txt
./splatche3input/veg2K_model_G_env4_LGM.txt
./splatche3input/veg2K_model_G_env5_earlyHolo.txt
./splatche3input/veg2K_model_G_env6_midHolo.txt
./splatche3input/veg2K_model_G_env7_current.txt
```

## Run simulations

We are now ready to run simulations, using ABCsampler as the wrapper program with the .input file to specify the simulation software and all other input files and settings. To run a single simulation (requires Linux 64-bit machine and python 2 [e.g., python 2.7], not python 3):

```
cd kiwi-iDDC/model_scripts/mantelliABC_v6_model_G/
./ABCsampler mantelliABC_v6_model_G.input
```

There will be several files created, but the main new output file will be as follows:

```
mantelliABC_v6_model_G_output_sampling1.txt
```

On each line of the ```output_sampling1.txt``` file will be the simulation replicate, the parameters, and the simulated summary statistics for that replicate.

The default scripts provided here are set up to perform only a single simulation, which may take several minutes. To peform a different number of simulation replicates, adjust the ```nbsims``` setting in the ```mantelliABC_v6_model_G.input``` file. For example, to perform 100 simulations, adjust line 9 to:

```
nbSims 100
```

In reality, for performing large numbers of simulations (e.g., hundreds of thousands) you will likely wish to submit jobs to a High-Performance Computing (HPC) cluster. Scripts are not provided as the setup will be highly specific to individual users.
