# Generating input files for demographic simulations

This document describes the steps needed to prepare model-specific input files for the demographic portion of each simulation. The simulations are conducted using the software [SPLATCHE3](https://www.splatche.com/splatche3).

The functions presented here are conceptually inspired by [code](https://github.com/KnowlesLab/X-ORGIN) written by Qixin He for X-ORIGIN [(He et al. 2017 Mol Ecol)](https://doi.org/10.1111/mec.14380), but have been completely rewritten in *R* and redeveloped for the purposes of the present project.

There are multiple input files for SPLATCHE3. Some of these are relatively straightforward and generic across models. Those files will be explained subsequently in Step 02. Instead, the purpose of this document is to describe the generation of the more complex input files that describe the dynamic landscape (i.e., changes in habitat suitability from the onset of the simulation at 140 ka until the pesent), which are specific to each individual iDDC model scenario.

The overall goal is to take rasters describing habitat suitability in different time periods (see [landscape_rasters](https://github.com/jordanbemmels/kiwi-iDDC/tree/main/landscape_rasters)), and convert them into input files that Splatche3 understands. There are four categories of model-specific input files:

```oriworld.asc``` - a map (ASCII-format) where pixel values represent unique combinations of habitat suitability through time</br>
```veg2K_XXX.asc``` - a file translating the oriworld pixel values into actual carrying capacities for time period XXX</br>
```dynamic_K.txt``` - describes when (number of generations) to apply the landscapes for each time period</br>
```densinit.txt``` - describes the starting locations (demes) in which individuals are initialized at the beginning of the simulation

## Preparing landscape rasters

Load required *R*-packages.

```
require(raster);
require(maps);
require(rgeos);
```

Load the [landscape_rasters](https://github.com/jordanbemmels/kiwi-iDDC/tree/main/landscape_rasters) for the different time periods in each simulation.

```
LIG_binned <- raster("./landscape_rasters/LIG_binned.tif");
postLIG_binned <- raster("./landscape_rasters/postLIG_binned.tif");
preLGM_binned <- raster("./landscape_rasters/preLGM_binned.tif");
LGM_binned <- raster("./landscape_rasters/LGM_binned.tif");
earlyHolo_binned <- raster("./landscape_rasters/earlyHolo_binned.tif");
midHolo_binned <- raster("./landscape_rasters/midHolo_binned.tif");
current_binned <- raster("./landscape_rasters/current_binned.tif");

oruanui_binned <- raster("./landscape_rasters/oruanui_binned.tif");
hatepe_binned <- raster("./landscape_rasters/hatepe_binned.tif");
maori_binned <- raster("./landscape_rasters/maori_binned.tif");
euro_binned <- raster("./landscape_rasters/euro_binned.tif");

LIG_fourLineages_binned <- raster("./landscape_rasters/LIG_fourLineages_binned.tif");
postLIG_fourLineages_binned <- raster("./landscape_rasters/postLIG_fourLineages_binned.tif");
preLGM_fourLineages_binned <- raster("./landscape_rasters/preLGM_fourLineages_binned.tif");
LGM_fourLineages_binned <- raster("./landscape_rasters/LGM_fourLineages_binned.tif");
earlyHolo_fourLineages_binned <- raster("./landscape_rasters/earlyHolo_fourLineages_binned.tif");
midHolo_fourLineages_binned <- raster("./landscape_rasters/midHolo_fourLineages_binned.tif");
current_fourLineages_binned <- raster("./landscape_rasters/current_fourLineages_binned.tif");

oruanui_fourLineages_binned <- raster("./landscape_rasters/oruanui_fourLineages_binned.tif");
hatepe_fourLineages_binned <- raster("./landscape_rasters/hatepe_fourLineages_binned.tif");
maori_fourLineages_binned <- raster("./landscape_rasters/maori_fourLineages_binned.tif");
euro_fourLineages_binned <- raster("./landscape_rasters/euro_fourLineages_binned.tif");
```

Crop to the area of interest for the simulation.

```
study_area_extent <- extent(c(171.6, 179.1, -41.7, -33.8));

LIG_sae <- crop(LIG_binned, study_area_extent);
postLIG_sae <- crop(postLIG_binned, study_area_extent);
preLGM_sae <- crop(preLGM_binned, study_area_extent);
LGM_sae <- crop(LGM_binned, study_area_extent);
earlyHolo_sae <- crop(earlyHolo_binned, study_area_extent);
midHolo_sae <- crop(midHolo_binned, study_area_extent);
current_sae <- crop(current_binned, study_area_extent);

oruanui_sae <- crop(oruanui_binned, study_area_extent);
hatepe_sae <- crop(hatepe_binned, study_area_extent);
maori_sae <- crop(maori_binned, study_area_extent);
euro_sae <- crop(euro_binned, study_area_extent);

LIG_fourLineages_sae <- crop(LIG_fourLineages_binned, study_area_extent);
postLIG_fourLineages_sae <- crop(postLIG_fourLineages_binned, study_area_extent);
preLGM_fourLineages_sae <- crop(preLGM_fourLineages_binned, study_area_extent);
LGM_fourLineages_sae <- crop(LGM_fourLineages_binned, study_area_extent);
earlyHolo_fourLineages_sae <- crop(earlyHolo_fourLineages_binned, study_area_extent);
midHolo_fourLineages_sae <- crop(midHolo_fourLineages_binned, study_area_extent);
current_fourLineages_sae <- crop(current_fourLineages_binned, study_area_extent);

oruanui_fourLineages_sae <- crop(oruanui_fourLineages_binned, study_area_extent);
hatepe_fourLineages_sae <- crop(hatepe_fourLineages_binned, study_area_extent);
maori_fourLineages_sae <- crop(maori_fourLineages_binned, study_area_extent);
euro_fourLineages_sae <- crop(euro_fourLineages_binned, study_area_extent);
```

## Create oriworld and veg2k files

Write a function to create the oriworld and veg2K files for a given model. The overall logic is to create a data frame of all possible combinations of binned habitat suitabilities across all the sequential time periods of the model, assign each possible combination a unique number, create the "oriworld" in which each raster cell will be assigned the appropriate unique number, and then create veg2K files that interpret what the carrying capacity actually means for each unique number in each of the sequential time periods.

```
writeOriVeg2K <- function(sequential_envs, env_names, oriworld_filename) {

	if (length(sequential_envs) != length(env_names)) {
		stop("ERROR: the number of environment names provided does not match the number of environment names");
	}
	
	# get the dimensions of the rasters - all must be the same!;
	temp_dimensions <- c(nrow(sequential_envs[[1]]), ncol(sequential_envs[[1]]));
	
	# create a data frame of all the values - each column is a single environment, and the rows represent the sequential values of the raster;
	values_df <- as.data.frame(getValues(sequential_envs[[1]]));
	if (length(sequential_envs) >= 2) {
		for (i in 2:length(sequential_envs)) {
			values_df <- cbind(values_df, getValues(sequential_envs[[i]]));
		}
	}
	values_df[is.na(values_df)] <- -9999; # convert all NA values to -9999;
	
	# assemble a table to contain all the possible combinations of values, for use in creating the veg2K files;
	veg_df <- unique(values_df);
	
	# create a vector that will become the oriworld - each value in the vector (each sequential position in the raster) will have its value replaced with the ROW NUMBER in veg_df to indicate the unique combination of values across all time periods for that particular cell - then, we can use the ROW NUMBER of veg_df to design our veg2K files;
	oriworld_vec <- rep(NA, nrow(values_df)); # initialize blank oriworld vector;
	for (i in 1:nrow(veg_df)) {
		print(paste0("Recoding oriworld, working on veg2K category ", i, " of ", nrow(veg_df)));
		# the equality_df is a dataframe set up exactly the same as values_df, where each value is a TRUE / FALSE depending whether it matches the corresponding value for the particular row (row i) of veg_df;
		equality_df <- data.frame(matrix(FALSE, nrow = nrow(values_df), ncol = ncol(values_df)));
		for (j in 1:ncol(equality_df)) {
			equality_df[ , j] <- values_df[ , j] == veg_df[i, j];
		}
		# only if ALL values for a row in equality_df are TRUE, then is that oriworld cell (= equality row) a matching row to the current veg_df row (i.e., a matching cell that has the desired set of values across all of the environments) - get a vector of which rows that is;
		temp_matching_row <- apply(equality_df, 1, function(x) sum(x) == ncol(equality_df));
		# update the values in oriworld_vec with the row number of veg_df;
		oriworld_vec[temp_matching_row] <- i;
	}
	
	# if the earliest time period raster is underwater, convert to -9999 to indicate the missing data value;
	oriworld_vec[values_df[ , 1] == -9999] <- -9999;
	
	# convert the oriworld back into a data frame with the original dimensions (nrow, ncol) - ensure to use byrow = T to get the correction lat-long orientation (this is because the order of cells in the raster, as accessed with getValues(), is from top left reading across the row, then move down one proceed across the next row, etc., i.e., the raster cells are initially also stored "byrow");
	oriworld_df <- as.data.frame(matrix(oriworld_vec, nrow = temp_dimensions[1], ncol = temp_dimensions[2], byrow = T));
	
	# write the oriworld file in .asc format;
	oriworld_con <- file(oriworld_filename, "w");
	writeLines(paste0("NCOLS ", temp_dimensions[2]), oriworld_con);
	writeLines(paste0("NROWS ", temp_dimensions[1]), oriworld_con);
	writeLines(paste0("XLLCORNER ", xmin(sequential_envs[[1]])), oriworld_con);
	writeLines(paste0("YLLCORNER ", ymin(sequential_envs[[1]])), oriworld_con);
	writeLines(paste0("CELLSIZE ", res(sequential_envs[[1]])[1]), oriworld_con);
	writeLines(paste0("NODATA_value -9999"), oriworld_con);
	write.table(oriworld_df, oriworld_con, quote = F, sep = " ", row.names = F, col.names = F);
	close(oriworld_con);
	
	# write the veg2K files - the first and third columns are the index (row number) and the second column is the variable in the format k_0, k_1, ..., k_10 for each of the carryinc capcities 0, 1, ..., 10;
	for (i in 1:length(env_names)) {
		temp_veg2K_df <- data.frame(1:nrow(veg_df), veg_df[ , i], 1:nrow(veg_df)); # assembly the data frame;
		temp_veg2K_df[temp_veg2K_df[ , 2] == -9999, 2] <- 0; # convert -9999 to 0 (i.e., all NA values on the map have carrying capacity zero);
		temp_veg2K_df[ , 2] <- paste0("k_", temp_veg2K_df[ , 2]); # transform the carrying capacity bins into variable names, i.e., 1 becomes k_1;
		write.table(temp_veg2K_df, paste0("veg2K_", env_names[i], ".txt"), quote = F, sep = "\t", row.names = F, col.names = F);
	}

}
```

Generate the files for a given model. An example is shown here for a relatively simple model (Model G) with seven time periods, and no volcanoes or human influence:

```
writeOriVeg2K(sequential_envs = c(LIG_sae, postLIG_sae, preLGM_sae, LGM_sae, earlyHolo_sae, midHolo_sae, current_sae), env_names = c("model_G_env1_LIG", "model_G_env2_postLIG", "model_G_env3_preLGM", "model_G_env4_LGM", "model_G_env5_earlyHolo", "model_G_env6_midHolo", "model_G_env7_current"), oriworld_filename = "oriworld_model_G.asc");
```

The command will generate eight output files. The file *oriworld_model_G.asc* is a single map where pixel values represent categories, each category being a unique combination of habitat-suitability values across the seven time periods. Because there are seven time periods with 11 habitat suitability bins each (from 0 to 10), we could theoretically have 11^7 = 19,487,171 different categories. In practice, many combinations are not found plus the number of pixels in the map is far below this number, so there are typically <1,000 unique categories.

The seven *veg2K* files (*veg2K_model_G_env1_LIG.txt*, *veg2K_model_G_env2_postLIG.txt*, *veg2K_model_G_env3_preLGM.txt*, *veg2K_model_G_env4_LGM.txt*, *veg2K_model_G_env5_earlyHolo.txt*, *veg2K_model_G_env6_midHolo.txt*, *veg2K_model_G_env7_current.txt*) represent each of the seven time periods. Let's inspect some lines of the first veg2K file (*veg2K_model_G_env1_LIG.txt*):

```
1	k_0	1
2	k_0	2
3	k_0	3
[...]
11	k_6	11
12	k_7	12
[...]
605	k_0	605
```

The first column is the vegetation category, the second column is the carrying capacity (here represented as k_0, k_6, k_7, etc., to indicate a value chosen from the prior), the third column is a name or description for the vegetation category (here, identical to first column for simplicity). This means that pixels with a value of 1 in the *oriworld_model_G.asc* file have a carrying capacity of "k_0" during the LIG. Pixels with a value of 11 have carrying capacity "k_6", value 12 have carrying capacity "k_7", etc. The carrying capacities k_0, k_6, etc., are variables that will be replaced according to the prior on maximum carrying capacity (Kmax), rather than actual values.

Now, inspect the *veg2k* file for the second time period (*veg2K_model_G_env2_postLIG.txt*):

```
1	k_0	1
2	k_0	2
3	k_0	3
[...]
11	k_6	11
12	k_0	12
[...]
605	k_0	605
```

The carrying capacity has not changed for any of the printed lines except for category 12, where it is now k_0. This means that after the transition to the second environment (postLIG), the carrying capacity that was previously k_7 in pixels with a value of 12 is now changed to k_0. Continuing this logic further for all seven time periods, there are 605 different unique combinations of carrying capacity for a given pixel (which we know since there are 605 rows in the *veg2k* files).

For more details, see the SPLATCHE3 user manual.


