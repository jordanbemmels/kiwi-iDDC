[![DOI](https://zenodo.org/badge/460195797.svg)](https://zenodo.org/badge/latestdoi/460195797)

This repository contains example commands for analyses run in the manuscript:

Jordan B. Bemmels, Oliver Haddrath, Rogan M. Colbourne, Hugh A. Robertson, Jason T. Weir. 2022. Legacy of supervolcanic eruptions on population genetic structure of brown kiwi. <i>Current Biology</i>, accepted in principle pending final submission.

For questions, contact Jordan Bemmels (jordan.bemmels@utoronto.ca).

There is no new software or methodological advance documented here; rather, the focus of the repository is to provide a supplement to the verbal explanations in the manuscript. In particular, the code documents the integrative Distributional, Demographic, and Coalescent (iDDC) model simulations and ABC procedure described in the manuscript.

There are three main sections (as well as directories containing example scripts and input files):

- ```01_Generate_demographicSim_input.md```, describing how to transform maps of habitat suitability for different time periods (e.g., from ecological niche models) into the necessary SPLATCHE3 input files required for iDDC simulations;
- ```02_Run_iDDC_simulations.md```, describing how to assemble additional software and scripts from published sources, and then run the iDDC model simulations using ABCtoolbox; and
- ```03_Perform_ABC.md```, describing how to process the output of the iDDC simulations, reduce the dimensionality of summary statistics using PLS regression, and perform the ABC steps for model choice and parameter estimation using ABCtoolbox.

Note that the naming convention of models is simplified here relative to the names in the manuscript. The models presented here ("Model_G", "Model_H", etc.) correspond to the following models in the manuscript:

**Model_G**: *noBarrier*</br>
**Model_H**: *ancientBarrier*</br>
**Model_I**: *noBarrier+volcanoes*</br>
**Model_J**: *ancientBarrier+volcanoes*</br>
**Model_M**: *fullBarrier*</br>
**Model_N**: *fullBarrier+volcanoes*</br>
**Model_S**: *ancientBarrier+Oruanui*</br>
**Model_T**: *ancientBarrier+Hatepe*</br>
**Model_yK**: *noBarrier+volcanoes+human*</br>
**Model_yL**: *ancientBarrier+volcanoes+human*</br>
**Model_yO**: *fullBarrier+volcanoes+human*</br>
**Model_yP**: *noBarrier+human*</br>
**Model_yQ**: *ancientBarrier+human*</br>
**Model_yR**: *fullBarrier+human*
