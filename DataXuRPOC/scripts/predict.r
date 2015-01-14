# uses the trained random forest model in scripts/rfmodel.rmd to predict the paym variable
# saves the prediction to the score.csv
suppressPackageStartupMessages(require(randomForest, quietly=TRUE))
scenario<-read.csv('tmp/scenario.csv')
load('scripts/rfmodel.rmd')
score<-predict(rf,scenario)
write.csv(score,'tmp/score.csv')