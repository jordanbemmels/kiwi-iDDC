# ABC model choice and parameter estimation

This document describes the ABC steps needed to select the best-performing model and estimate its parameters, after the iDDC simulations have been performed for each model. The necessary scripts and input files for this step are provided in the [ABC_scripts](https://github.com/jordanbemmels/kiwi-iDDC/tree/main/ABC_scripts) directory.

## Assemble all simulations and quality control

If the scripts have been run on muliple cores of an HPC cluster (as will likely be the case), the individual output files (simulated summary statistics) will need to be combined into a single file containing all simulations for each model. While doing so, we will also take the opportunity to do several quality checks and exclude any failed individual simulations or entire simulation batches.

Simulations to remove are as follows:
- Entire simulation batches that have an identical random seed as an earlier batch of simulations (we tried to avoid this, but best to check that it did not occur). The random seed is recorded in the ABCsampler.log file when running the simulations.
- Individual simulations where summary statistics are identical to those of the immediately previous line. This sometimes occurs in iDDC models where an error occurs in the second simulation (typically not all populations are colonized before the end of the simulation, so SNP data cannot be simulated), and the the temporary summary statistic files from the first simulation are not updated but are instead re-printed for the second simulation. We set the lower limits on carrying capacity and migration rate in the priors to prevent this from happening, but should still check that it did not occur.
- Individual simulations where the order of the summary statistics has been printed incorrectly or only partially printed. This rarely occurs if all sampling sites have been colonized by the end of the simulation, yet the number of individuals temporarily dipped below the requested number to sample in one or more of the sampling sites (e.g., due to model stochasticity), and thus only some of the summary statistics could be calculated and printed. In the kiwi project, we can detect this rare situation if the statistic tot_K is not equal to 2 (K is the number of alleles and should always be 2 for biallelic SNPs) or if any of the K values for individual populations (K_1, K_2, etc.) is equal to 1, indicating that there is no variation whatsoever across any of the 1,250 simulated SNPs.

These steps are implemented in [ABC_scripts/ABC00_merge_sims_remove_failed_v6.R](https://github.com/jordanbemmels/kiwi-iDDC/tree/main/ABC_scripts/ABC00_merge_sims_remove_failed_v6.R). The file-organization system is described in the file, but other users will likely need to substantially edit this file depending on their own file organization and output from the HPC cluster. However, it is provided here in order to document the code for checking and removing simulations.

After updating paths in the first few lines, the script can be run:

```
cd ABC_scripts
Rscript ABC00_merge_sims_remove_failed_v6.R
```

The output will be a single file for each model, with a maximum of 100,000 simulations per file that passed quality control. If fewer simulations are available, a warning will be printed and the user should perform additional simulations then re-run the script. An example file name might be ```mantelliABC_v6_model_G_100K.txt```, but this file will be very large and for demonstration purposes we only provide the first 10 simulations per model, e.g., ```ABC_scripts/mantelliABC_v6_model_G_10sims.txt```.

## Select 10,000 simulations per model

We now select the first 10,000 simulations per model from each of the 12 models, and combine them into a single file. The purpose is to gather a subset of simulations from all 12 models that will be used in the PLS regression below. Modify the paths and settings in the first lines of the script [ABC_scripts/ABC01a_select_10Ksims_per_model.py](https://github.com/jordanbemmels/kiwi-iDDC/blob/main/ABC_scripts/ABC01a_select_10Ksims_per_model.py) and then run as follows:

```
cd ABC_scripts
python ABC01a_select_10Ksims_per_model.py
```

The output file is ```combined_10K_per_model_v6.5.txt``` and is simply the 120,000 selected simulations (12 models x 10,000 per model).

## Perform the PLS regression

The Partial Least Squares (PLS) regression is used to reduce dimensionality of the genetic summary statistics. The script [ABC_scripts/ABC01b_find_pls_mantelli_v6.5_noPsi.R](https://github.com/jordanbemmels/kiwi-iDDC/blob/main/ABC_scripts/ABC01b_find_pls_mantelli_v6.5_noPsi.R) is only slightly modified from one provided in the [ABCtoolbox](http://cmpg.unibe.ch/software/ABCtoolbox/) manual (see further info in script itself). It standardizes and boxcox-transforms summary statistics, performs the PLS, and outputs a table that can be later used to calculate PLS linear combinations for additional summary statistics using ABCtoolbox. We perform the PLS regression here only on our selected subset of 120,000 simulations for computational efficiency, and then will apply the boxcox and PLS formula to our full set of simulations in a subsequent step. To run the script:

```
cd ABC_scripts
Rscript ABC01b_find_pls_mantelli_v6.5_noPsi.R
```

The output file are as follows:
- ```Routput_noPsicombined_10K_per_model.txt```: formula for transforming data and calculating PLS components on additional sets of summary statistics
- ```RMSE_noPsicombined_10K_per_model.txt.pdf```: RMSEP plot for different numbers of PLS components
- ```Rplots.pdf```: plots showing selection of lambda parameter for boxcox transformation of summary statistics
- ```Rojb_myplsr_noPsi.R```: the myplsr R object saved for future use

After this, we can slightly reformat the PLS formula (e.g., add a header) and give it a more appropriate name for future use. We also reduce the number of PLS components to calculate (in the example, reduced to only 8 components) to avoid calculating a huge number of components on the full datasets.

```
cd ABC_scripts
Rscript ABC01c_reformat_boxcox_defs_v6.5_noPsi.R
```

The output file ready for downstream use is ```boxcox_params_mantelli_v6.5_noPsi.txt```.

## Calculate PLS components for all simulations and empirical data

We are ready to perform boxcox transformation and calculate the PLS linear combinations on the full set of 100,000 simulations for each model. This is done using the *transformer_64bit* script distributed with ABCtoolbox, and available for download [here](http://cmpg.unibe.ch/software/ABCtoolbox/).

```
cd ABC_scripts
chmod +x transformer_64bit
./transformer_64bit boxcox_params_mantelli_v6.5_noPsi.txt mantelliABC_v6_model_G_100K.txt mantelliABC_v6.5_model_G_100K_transformed_noPsi.txt boxcox
./transformer_64bit boxcox_params_mantelli_v6.5_noPsi.txt mantelliABC_v6_model_H_100K.txt mantelliABC_v6.5_model_H_100K_transformed_noPsi.txt boxcox
[...]
```

The outfile (e.g., ```mantelliABC_v6.5_model_G_100K_transformed_noPsi.txt```) now contain additional columns representing the PLS linear combinations for all 100,000 simulations. There are many unnecessary columns so let's print only the three columns of the model parameters (2-4) and eight PLS components (43-50) in a new directory (*ABCestimator_input_noPsi*):

```
cd ABC_scripts
cut -f 2-4,43-50 mantelliABC_v6.5_model_G_100K_transformed_noPsi.txt > ABCestimator_input_noPsi/mantelliABC_v6.5_model_G_100K_transformed_noPsi.txt
cut -f 2-4,43-50 mantelliABC_v6.5_model_H_100K_transformed_noPsi.txt > ABCestimator_input_noPsi/mantelliABC_v6.5_model_H_100K_transformed_noPsi.txt
[...]
```

We also need to transform the empirical summary statistics in the same way.

```
cd ABC_scripts
chmod +x transformer_64bit
./transformer_64bit boxcox_params_mantelli_v6.5_noPsi.txt empiricalSS.obs empiricalSS_mantelliABC_v6.5_transformed_noPsi.txt boxcox
```

Now, the PLS linear combinations for the empirical summary statistics are printed in ```empiricalSS_mantelliABC_v6.5_transformed_noPsi.txt```. In order to define which summary statistics to use and select exactly six PLS components (or however many you desire, can be ≤8 as we retained eight PLS components in the simulated data), we can print only the relevant columns in the empirical data. Note that the summary statistics above had eight PLS components retained, but we do not need to further cut the simulated statistics; we only need to cut the empirical data as that is the input file that will be used to define which summary statistics to use in the ABC step below.

```
cd ABC_scripts
cut -f 14-19 empiricalSS_mantelliABC_v6.5_transformed_noPsi.txt > ABCestimator_input_noPsi/empiricalSS_mantelliABC_v6.5_transformed_noPsi_6PLS.txt
```

## Perform ABC

The actual ABC step is performed with the *ABCestimator_linux64* script that can be downloaded from [ABCtoolbox](http://cmpg.unibe.ch/software/ABCtoolbox/). Download this script and place it here: ```ABC_scripts/ABCestimator_input_noPsi/ABCestimator_linux64```.

In the previous step, we created ```ABC_scripts/ABCestimator_input_noPsi/mantelliABC_v6.5_model_G_100K_transformed_noPsi.txt``` (and equivalent files for subsequent models), and ```ABC_scripts/ABCestimator_input_noPsi/empiricalSS_mantelliABC_v6.5_transformed_noPsi_6PLS.txt```. These are the transformed summary statistics for the simulations for Model G (and subsequent models in other files), and the empirical data, respectively. We also need to define the parameters of the ABC step, in the file ```ABC_scripts/ABCestimator_input_noPsi/mantelliABC_v6.5_generic.input```. This file indicates which columns are the model parameters in the simulation input file, how many simulations to retain, and other parameters (see ABCtoolbox manual for more details).

To perform the ABC estimation for each model:

```
cd ABC_scripts/ABCestimator_input_noPsi
chmod +x ABCestimator_linux64 
./ABCestimator_linux64 mantelliABC_v6.5_generic.input simName=mantelliABC_v6.5_model_G_100K_transformed_noPsi.txt obsName=empiricalSS_mantelliABC_v6.5_transformed_noPsi_6PLS.txt outputPrefix=mantelliABC_v6.5_model_G_100K_noPsi_6PLS > mantelliABC_v6.5_model_G_100K_noPsi_6PLS_terminalOut.txt
./ABCestimator_linux64 mantelliABC_v6.5_generic.input simName=mantelliABC_v6.5_model_H_100K_transformed_noPsi.txt obsName=empiricalSS_mantelliABC_v6.5_transformed_noPsi_6PLS.txt outputPrefix=mantelliABC_v6.5_model_H_100K_noPsi_6PLS > mantelliABC_v6.5_model_H_100K_noPsi_6PLS_terminalOut.txt
[...]
```

For each model (here, examples shown for Model G), the following files are created:
- ```mantelliABC_v6.5_model_G_100K_noPsi_6PLS_terminalOut.txt```, terminal output
- ```mantelliABC_v6.5_model_G_100K_noPsi_6PLSBestSimsParamStats_Obs0.txt```, 500 retained (best-fitting) simulations
- ```mantelliABC_v6.5_model_G_100K_noPsi_6PLSL1DistancePriorPosterior.txt```, L1 distance between parameter prior and posterior distributions
- ```mantelliABC_v6.5_model_G_100K_noPsi_6PLSPosteriorCharacteristics_Obs0.txt```, summary of the parameter posterior distributions
- ```mantelliABC_v6.5_model_G_100K_noPsi_6PLSPosteriorEstimates_Obs0.txt```, complete parameter posterior distributions, with GLM adjustment
- ```mantelliABC_v6.5_model_G_100K_noPsi_6PLSTruncatedPrior_Obs0.txt```, raw parameter distributions of the 500 retained simulations

The most relevant files are the ```terminalOut.txt``` file, which prints the marginal density of the model and the p-value, and the ```PosteriorCharacteristics_Obs0.txt``` with the parameter estimates for each model.

To select the best-fitting model, inspect the marginal density of each  model in the ```terminalOut.txt``` files. The selected model is the one with the highest marginal density. To assess relative support for one model over another, Bayes Factors can be calculated by dividing the marginal density of a higher-supported model by the marginal density of a lower-supported model.
