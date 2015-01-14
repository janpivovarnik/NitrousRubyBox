# train,r creates the random forest model and saves it to the scripts/rfmodel.rmd
model<-read.csv('tmp/model.csv')
input <- names(model)[4:34]
target  <- 'paym'
suppressPackageStartupMessages(require(randomForest, quietly=TRUE))
rf <- randomForest(paym ~ .,data=model[,c(input, target)], ntree=80,mtry=5,importance=TRUE,na.action=na.roughfix,replace=FALSE)
save(rf,file='scripts/rfmodel.rmd')