# modified from code provided in Fig. 9 (page 45) of the ABCtoolbox manual, v. September 30, 2009, by Daniel Wegmann, Christoph Leuenberger, and Laurent Excoffier;
# substnatially modified lines initialed in comments wtih "JBB";

#open File
numComp<-20;

directory<-"WORKING_DIRECTORY"; # JBB edits;
filename<-"combined_10K_per_model_v6.5.txt"; # JBB edits;

#read file
a<-read.table(paste(directory, filename, sep=""), header=T, skip=0); # JBB edits to remove nrows = 10000, because we want to read the entire file - important! we need to include the entire file to have sims represented from all models;
print(names(a));
stats<-a[,c(43:111)]; params<-a[,c(2:4)]; rm(a); # JBB edits to fit mantelli_v6, without including K nor psi as sstats;
 
#standardize the params
for(i in 1:length(params)){params[,i]<-(params[,i]-mean(params[,i]))/sd(params[,i]);}

#force stats in [1,2]
myMax<-c(); myMin<-c(); lambda<-c(); myGM<-c();
for(i in 1:length(stats)){
	myMax<-c(myMax, max(stats[,i]));
	myMin<-c(myMin, min(stats[,i]));
	stats[,i]<-1+(stats[,i]-myMin[i])/(myMax[i]-myMin[i]);
}

#transform statistics via boxcox  
library("MASS");	
for(i in 1:length(stats)){		
	print(paste0("finding lambda for statistic ", i, " of ", ncol(stats))); # JBB edits - add this line to keep track of progress as this is extraordinarily slow;
	d<-cbind(stats[,i], params);
	mylm<-lm(as.formula(d), data=d)			
	myboxcox<-boxcox(mylm, lambda=seq(-50, 80, 1/10), plotit=T, interp=T, eps=1/50); # JBB edits: edited search space for lambda parameters;
	lambda<-c(lambda, myboxcox$x[myboxcox$y==max(myboxcox$y)]);			
	print(paste(names(stats)[i], myboxcox$x[myboxcox$y==max(myboxcox$y)]));
	myGM<-c(myGM, exp(mean(log(stats[,i]))));			
}

#standardize the BC-stats
myBCMeans<-c(); myBCSDs<-c();
for(i in 1:length(stats)){
	stats[,i]<-(stats[,i]^lambda[i] - 1)/(lambda[i]*myGM[i]^(lambda[i]-1));	
	myBCSDs<-c(myBCSDs, sd(stats[,i]));
	myBCMeans<-c(myBCMeans, mean(stats[,i]));		
	stats[,i]<-(stats[,i]-myBCMeans[i])/myBCSDs[i];
}

#perform pls
library("pls");
myPlsr<-plsr(as.matrix(params) ~ as.matrix(stats), scale=F, ncomp=numComp); # JBB edits: we do not use the validation, which takes forever - this is fine, according to the ABCtoolbox manual "Note that an RMSEP plot can also be generated if no validation is done (removing validation='LOO' from the plsr call). In this case the prediction error is approximated, which is much faster.";

#write pls to a file
myPlsrDataFrame<-data.frame(comp1=myPlsr$loadings[,1]);
for(i in 2:numComp) { myPlsrDataFrame<-cbind(myPlsrDataFrame, myPlsr$loadings[,i]); } 
write.table(cbind(names(stats), myMax, myMin, lambda, myGM, myBCMeans, myBCSDs, myPlsrDataFrame), file=paste(directory, "Routput_noPsi", filename, sep=""), col.names=F, row.names=F, sep="\t", quote=F); # JBB EDITS output name (_noPsi);

# JBB edits - addition of new step: write myPlsr object to a file for future use;
save(myPlsr, file = paste0(directory, "Robj_myplsr_noPsi.R"));

#make RMSE plot
pdf(paste(directory, "RMSE_noPsi", filename, ".pdf", sep="")); # JBB EDITS output name (_noPsi);
plot(RMSEP(myPlsr));
dev.off();
