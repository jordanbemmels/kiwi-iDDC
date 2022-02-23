##### Code is to reformat the boxcox definitions in the Routput[...].txt file, and prepare a final file that can be used with linearTranformer script from ABCtoolbox. We do not change any of the boxcox parameters, we simply (1) add a header, and (2) reduce to the desired number of PLS components, which must be decided in advance by inspecting the RMSE[...].pdf output. #####

##### USER SETS MANUALLY #####

n_PLS <- 8;

outfile_suffix <- "mantelli_v6.5_noPsi";

boxcox <- read.table("Routput_noPsicombined_10K_per_model_v6.5.txt", sep = "\t", header = F, stringsAsFactors = F);

##############################

boxcox <- boxcox[ , 1:(7 + n_PLS)]; # remove unwanted extra PLS columns;

# Note that on p. 21 of the ABCtoolbox manual, it says the 2nd and 3rd columns should be min and max, respectively. However, the default output from running step 2 is to have the columns be max and min, respectively (i.e., reverse order), as implemented here;

colnames(boxcox) <- c("//sstat", "max", "min", "labmda", "geometric_mean", "boxcox_mean", "boxcox_sd", paste0("comp", 0:(n_PLS-1)));

write.table(boxcox, paste0("boxcox_params_", outfile_suffix, ".txt"), sep = "\t", row.names = F, col.names = T, quote = F);
