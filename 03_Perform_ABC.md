# ABC model choice and parameter estimation

This document describes the ABC steps needed to select the best-performing model and estimate its parameters, after the iDDC simulations have been performed for each model. The necessary scripts and input files for this step are provided in the [ABC_scripts](https://github.com/jordanbemmels/kiwi-iDDC/tree/main/ABC_scripts) directory.

## Assemble all simulations and quality control

If the scripts have been run on muliple cores of an HPC cluster (as will likely be the case), the individual output files (simulated summary statistics) will need to be combined into a single file containing all simulations for each model. While doing so, we will also take the opportunity to do several quality checks and exclude any failed individual simulations or entire simulation batches.

Simulations to remove are as follows:
- Entire simulation batches that have an identical random seed as an earlier batch of simulations (we tried to avoid this, but best to check that it did not occur). The random seed is recorded in the ABCsampler.log file when running the simulations.
- Individual simulations where summary statistics are identical to those of the immediately previous line. This sometimes occurs in iDDC models where an error occurs in the second simulation (typically not all populations are colonized before the end of the simulation, so SNP data cannot be simulated), and the the temporary summary statistic files from the first simulation are not updated but are instead re-printed for the second simulation. We set the lower limits on carrying capacity and migration rate in the priors to prevent this from happening, but should still check that it did not occur.
- Individual simulations where the order of the summary statistics has been printed incorrectly or only partially printed. This rarely occurs if all sampling sites have been colonized by the end of the simulation, yet the number of individuals temporarily dipped below the requested number to sample in one or more of the sampling sites (e.g., due to model stochasticity), and thus only some of the summary statistics could be calculated and printed. In the kiwi project, we can detect this rare situation if the statistic tot_K is not equal to 2 (K is the number of alleles and should always be 2 for biallelic SNPs) or if any of the K values for individual populations (K_1, K_2, etc.) is equal to 1, indicating that there is no variation whatsoever across any of the 1,250 simulated SNPs.

