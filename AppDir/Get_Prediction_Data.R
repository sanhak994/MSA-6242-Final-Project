##
##
## This code takes our main data file Prediction_inflation_adjusted.csv
## and pulls out the predictors and responses of importance to the predictor app
##
## Jared Babcock

dat <- read.csv("Prediction_inflation_adjusted.csv", header=TRUE)
dat.df <- as.data.frame(dat)

exp.ratio.col <- dat.df$INSTRUCTION_EXPENDITURE/dat.df$TOTAL_EXPENDITURE

dat.df <- cbind(dat.df,exp.ratio.col)

colnames(dat.df)[48] <- "INSTR_TOTAL_EXP_RATIO"

dat.df.reduced <- dat.df[,c(3,48,12,13,18,30,31,32,35,37,42:44,46,14,24)]

write.csv(dat.df.reduced,"Prediction_data.csv", row.names=FALSE)

