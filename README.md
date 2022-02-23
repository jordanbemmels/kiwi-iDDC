This repository contains example commands for analyses run in the manuscript:

Jordan B. Bemmels, Oliver Haddrath, Rogan M. Colbourne, Hugh A. Robertson, Jason T. Weir. Legacy of supervolcanic eruptions on population genetic structure of kiwi. *In review.*

For questions, contact Jordan Bemmels (jordan.bemmels@utoronto.ca).

There is no new software documented here; rather, the focus of the repository is to provide a supplement to the verbal explanations in the manuscript. In particular, the code documents the integrative Distributional, Demographic, and Coalescent (iDDC) model simulations and ABC procedure described in the manuscript.

There are three main sections (as well as directories containing example scripts and input files):

- ```01_Generate_demographicSim_input.md```, describing how to transform maps of habitat suitability for different time periods (e.g., from ecological niche models) into the necessary SPLATCHE3 input files required for iDDC simulations;
- ```02_Run_iDDC_simulations.md```, describing how to assemble additional software and scripts from published sources, and then run the iDDC model simulations using ABCtoolbox; and
- ```03_Perform_ABC.md```, descriing how to process the output of the iDDC simulations, reduce the dimensionality of summary statistics using PLS regression, and perform the ABC steps for model choice and parameter estimation using ABCtoolbox.
