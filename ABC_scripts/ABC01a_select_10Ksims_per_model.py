##### Code is to select 10,000 simulations from each of the models and combine them into a single file. #####

########## User sets these each time ##########

outfile_10K = "combined_10K_per_model_v6.5.txt"

input_files_dir = "PATH_TO_DIRECTORY_WITH_INPUT_SIMULATION_FILES"

input_files = ["mantelliABC_v6_model_G_100K.txt", "mantelliABC_v6_model_H_100K.txt", "mantelliABC_v6_model_I_100K.txt", "mantelliABC_v6_model_J_100K.txt", "mantelliABC_v6_model_yK_100K.txt", "mantelliABC_v6_model_yL_100K.txt", "mantelliABC_v6_model_M_100K.txt", "mantelliABC_v6_model_N_100K.txt", "mantelliABC_v6_model_yO_100K.txt", "mantelliABC_v6_model_yP_100K.txt", "mantelliABC_v6_model_yQ_100K.txt", "mantelliABC_v6_model_yR_100K.txt"]

###############################################

import linecache

input_file_paths = [input_files_dir + "/" + s for s in input_files]

fout = open(outfile_10K, "w")
for i in range(len(input_file_paths)):
	# if it's the first (index = 0) input file, print the header;
	if i == 0:
		for j in range(10002):
			# write one line at a time, the first 10,000 lines plus header
			fout.write(linecache.getline(input_file_paths[i], j))
	else:
		for j in range(2, 10002):
			# write one line at a time, the first 10,000 lines excluding header
			fout.write(linecache.getline(input_file_paths[i], j))
fout.close()


