# Running iDDC model simulations

This document describes how to compile directories for each of the iDDC models, and how to run the simulations.

Most of the files are already partly compiled and located in the [model_scripts](https://github.com/jordanbemmels/kiwi-iDDC/tree/main/model_scripts) directory, but some additional organization is needed. In particular, users will need to add executable files for published simulation software, and generic iDDC scripts that have previously been published, as described below.

## Compiling a generic *calSumStat* directory

A directory named *calSumStat* is required, and is generic (i.e., identical) for all models. This directory contain the scripts necessary for converting raw SNP genotypes simulated by SPLATCHE3 into genetic summary statistics.

A complete version of *calSumStat* is not provided here, because it will contain executable scripts from published software and publicly-available iDDC scripts written by other authors that are not my own intellectual property. Thus, it will be necessary to gather a few scripts from other sources.

A complete version of a *calSamStat* directory with scripts useful for iDDC modelling has previously been published as part of [X-ORIGIN](https://github.com/KnowlesLab/X-ORGIN) software ([He et al. 2017 Mol Ecol](https://doi.org/10.1111/mec.14380)].

*He, Q, JR Prado, and LL Knowles. 2017. Inferring the geographic origin of a range expansion: Latitudinal and longitudinal coordinates inferred from genomic data in an ABC framework with the program X-ORIGIN. Mol Ecol, **26**: 6908-6920.*

Begin by downloading X-ORIGIN v1.0 (XOrigin_v1) from [https://github.com/KnowlesLab/X-ORGIN/releases](https://github.com/KnowlesLab/X-ORGIN/releases). Extract and copy ```./X-ORIGIN/example/calSumStat``` to a convenient working directory.

The downloaded ```calSumStat``` directory contains the following files:

```
arl_run.ars # input file for Arlequin
arlsumstat # executable file for Arlequin
calPsi.r # calculates directionality index (psi statistic)
calSumStat.py # controls the execution of Arlequin
empiricalSS.obs # observed summary statistics from the empirical dataset
re_functions_resistance.r # additional functions loaded by calPsi.r
ssdefs.txt # input file for Arlequin
```

We do not need to modify *calPsi.r*, *calSumStat.py*, or *re_functions_resistance.r*. You may need to replace the default *arlsumstat* executable with a version that works on your own system, if the downloaded one does not work. The remaining three files (*arl_run.ars*, *empiricalSS.obs*, and *ssdefs.txt*) are specific to the example downloaded from the X-ORIGIN repository. These three files need to be replaced with updated versions specific to the kiwi-iDDC project, which are located in [kiwi-iDDC/model_scripts/](https://github.com/jordanbemmels/kiwi-iDDC/tree/main/model_scripts/calSumStat_kiwi_replacementFiles).







