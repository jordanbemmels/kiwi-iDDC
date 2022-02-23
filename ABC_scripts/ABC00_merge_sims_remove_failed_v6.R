##### Code is to merge all the simulations of a given set of parent directories (corresponding to a particular model), and also print any failed simulations. Then we will also restrict to the number of simulations required. #####
# The code is set up assuming that you have multiple parent directories. Within each parent dir, there are multiple subdirectories that begin with the model prefix (corrseponding to runs from different cores on a HPC cluster). Each subdirectory contains a file ending in "_output_sampling1.txt", which has the simulated summary statistics.
# For example:
	# ./mantelliABC_v6_model_X_DATE1/mantelliABC_v6_model_X_subdir01/mantelliABC_v6_model_X_output_sampling1.txt;
	# ./mantelliABC_v6_model_X_DATE1/mantelliABC_v6_model_X_subdir02/mantelliABC_v6_model_X_output_sampling1.txt;
	# [...];
	# ./mantelliABC_v6_model_X_DATE2/mantelliABC_v6_model_X_subdir01/mantelliABC_v6_model_X_output_sampling1.txt;
	# etc.;

##### USER SETS THESE OPTIONS EACH TIME #####

setwd("USER_WORKING_DIRECTORY_PATH"); # the main working directory;

parent_dirs <- c("mantelliABC_v6_model_X_DATE1", "mantelliABC_v6_model_X_DATE2"); # You may have multiple parent directories, e.g., different sets of simulations from different dates. 
model_prefix <- "mantelliABC_v6_model_X"; # prefix for the model, all simulations from the same model have the same prefix;
final_outfile_name <- "mantelliABC_v6_model_X_100K.txt"; # desired output name for the final merged output file;

required_sims <- 100000; # maximum number of simulations to print in the final merged output file;

N_PARAMS <- 18; # the number of columns in the simulation files that are parameters, rather than sstats - should be the same for all models: 1 Sim + 3 log-scale parameters + 3 non-log transformed params + 11 transformed density bins = 18;

##############################
##############################
##############################

##### Merge the simulations #####

# get the paths of the files to be merged;
# also keep track of the randomSeed - we do not want to include any batches that by chance have the same random seed (I have set the scripts up to avoid this by chance; initially I had some logic that didn't make sense and have mostly fixed it now, but it's still possible that the randomSeed might be identical);

files_to_merge <- NA;
randomSeed_files <- NA;

for (i in 1:length(parent_dirs)) {

	temp_batches <- dir(parent_dirs[i], pattern = paste0("^", model_prefix));
	
	for (j in 1:length(temp_batches)) {

		temp_output_file <- list.files(paste0(parent_dirs[i], "/", temp_batches[j]), pattern = "*_output_sampling1.txt");
		files_to_merge <- c(files_to_merge, paste0(parent_dirs[i], "/", temp_batches[j], "/", temp_output_file));
		temp_output_file <- NA; #reset;

		randomSeed_files <- c(randomSeed_files, paste0(parent_dirs[i], "/", temp_batches[j], "/ABCsampler.log"));

	}

}

files_to_merge <- files_to_merge[!(is.na(files_to_merge))];
randomSeed_files <- randomSeed_files[!(is.na(randomSeed_files))];

# remove any files from our list to merge if they have identical randomSeeds;

randomSeeds <- NA;

for (i in 1:length(randomSeed_files)) {

	temp_seedLine <- read.table(randomSeed_files[i], skip = 3, nrow = 1, header = F, stringsAsFactors = F, sep = "");
	randomSeeds <- cbind(randomSeeds, temp_seedLine$V6);

}

randomSeeds <- randomSeeds[!(is.na(randomSeeds))];

files_to_merge <- files_to_merge[!(duplicated(randomSeeds))]; # remove files from our list that are duplicates of earlier randomSeeds;

if (sum(duplicated(randomSeeds)) > 0) {
	print(paste0("WARNING: ", sum(duplicated(randomSeeds)), " simulation batches entirely removed because they had identical randomSeeds to earlier batches!"));
}

# ready to continue;

# set up a temp outfile;

temp_merged_filename <- paste0(model_prefix, "_merged_temp.txt");

# print the header (first line) of the first file, it should be the same for all files;

header_cmd <- paste0("head -1 ", files_to_merge[1], " > ", temp_merged_filename);
system(header_cmd);

# add the simulations from all the files, excluding the header (first line);
# "tail -n +2" prints starting from the second line only;
# using ">>" appends rather than overwrites the existing file;

for (i in 1:length(files_to_merge)) {

	temp_cat_cmd <- paste0("tail -n +2 ", files_to_merge[i], " >> ", temp_merged_filename);
	#print(temp_cat_cmd);
	system(temp_cat_cmd);

}

##### Scan the merged outfile for duplicates and remove #####

# print the non-duplicated lines to a new outfile;

# uniq -u will print only unique lines;
# "Note: uniq isn’t able to detect the duplicate lines unless they are adjacent to each other" but this is OK for us as we are only interested in adjacent duplicates anyway (non-adjacent duplicates should not occur);
# however, we are interested in only if the sstats are duplicated - the error lines will have identical sstats but will have non-identical simulation parameters (which are bogus for the second line);
	# to ignore the parameter columns, use -f N_PARAMS, then these first N_PARAMS columns are not considered when determining whether the line is duplicated;
# note that unfortunately this setup removes BOTH of the lines with identical sstats, but this is not a big deal, the first line is a valid simulation but is completely random (no bias towards particular parameters) so it is simply removing it;

temp_nonDuplicate_filename <- paste0(model_prefix, "_nonDuplicate_temp.txt");

uniq_cmd <- paste0("uniq -u -f ", N_PARAMS, " ", temp_merged_filename, " > ", temp_nonDuplicate_filename);

system(uniq_cmd);

n_merged <- length(readLines(temp_merged_filename));
n_nonDuplicate <- length(readLines(temp_nonDuplicate_filename));

n_duplicates <- (n_merged - n_nonDuplicate) / 2;

print(paste0(n_duplicates, " instances of failed sims with identical sstats found."));
print(paste0(n_duplicates * 2, " sims removed corresponding to both lines having identical sstats"));

##### Update: remove an additional type of failed simulation, where the sstats are in the wrong order #####

# it can (rarely) occur that the sstats were somehow printed in the wrong order by the simulation program and are nonsensical, this is a very severe problem for downstream purposes - simplest check that order of sstats is correct is if tot_K is equal to ~2 (here, allow > 1.95 for some leeway; no other sstat should have values > 1.95);
# there are also some cases where tot_K=2 but the sstats are STILL jumbled, for example heterozygosity in populations 7 and 8 (H_7, H_8) is problematic when K_7 and K_8 is equal to 1 (indicating no variation at any SNP in these populations) - remove these also, by identifying any lines where any K_values are equal to 1;

temp_sstatOrderFine_filename <- paste0(model_prefix, "_sstatOrderFine_temp.txt");

sstatFilter_cmd <- paste0("awk 'NR==1 || ($42 > 1.95 && $30!=1 && $31!=1 && $32!=1 && $33!=1 && $34!=1 && $35!=1 && $36!=1 && $37!=1 && $38!=1 && $39!=1 && $40!=1)' ", temp_nonDuplicate_filename, " > ", temp_sstatOrderFine_filename); # checks if it's the first line (NR==1), OR (column 42 (tot_K) is greater than 1.95 and all of the K values (columns 30 to 40) are not equal to 1);

system(sstatFilter_cmd);

n_sstatOrderFine <- length(readLines(temp_sstatOrderFine_filename));

n_sstatOrderWrong <- n_nonDuplicate - n_sstatOrderFine;

print(paste0(n_sstatOrderWrong, " sims removed where the ordering of the sstats was jumbled"));

##### Print the desired number of lines #####

awk_cmd <- paste0("awk 'NR<=", required_sims + 1, "' ", temp_sstatOrderFine_filename, " > ", final_outfile_name);

system(awk_cmd);

n_retained_final <- length(readLines(final_outfile_name));

if (n_retained_final == required_sims + 1) {
	print(paste0("Final outfile has exactly ", n_retained_final - 1, " sims"));
} else {
	print(paste0("WARNING: final outfile has exactly ", n_retained_final - 1, " sims"));
	print(paste0("WARNING: ", required_sims, " were requested"));
	print(paste0("WARNING: a sufficient number of sims were not found!"));
}

##### Remove the temp files #####

system(paste0("rm ", temp_merged_filename));
system(paste0("rm ", temp_nonDuplicate_filename));
system(paste0("rm ", temp_sstatOrderFine_filename));

print(paste0("Final outfile generated: ", final_outfile_name));
