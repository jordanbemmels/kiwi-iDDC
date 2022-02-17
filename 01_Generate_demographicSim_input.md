This document describes the steps needed to prepare model-specific input files for the demographic portion of each simulation. The simulations are conducted using the software [SPLATCHE3](https://www.splatche.com/splatche3).

The functions presented here are conceptually inspired by [code](https://github.com/KnowlesLab/X-ORGIN) written by Qixin He for X-ORIGIN [(He et al. 2017 Mol Ecol)](https://doi.org/10.1111/mec.14380), but have been completely rewritten in *R* and redeveloped for the purposes of the present project.

There are multiple input files for SPLATCHE3. Some of these are relatively straightforward and generic across models. Those files will be explained subsequently in Step 02. Instead, the purpose of this document is to document the generation of the more complex input files that describe the dynamic landscape (i.e., changes in habitat suitability from the onset of the simulation at 140 ka until the pesent), which are specific to each individual iDDC model scenario.

The overall goal is to take rasters describing habitat suitability in different time periods (see [landscape_rasters](https://github.com/jordanbemmels/kiwi-iDDC/tree/main/landscape_rasters)), and convert them into input files that Splatche3 understands. There are three categories of model-specific input files:

```oriworld.asc``` - a map (ASCII-format) where pixel values represent unique combinations of habitat suitability through time
```veg2K_XXX.asc``` - a file translating the oriworld pixel values into actual carrying capacities for time period XXX
```densinit.txt``` - describes the starting locations (demes) in which individuals are initialized at the beginning of the simulation</br>
