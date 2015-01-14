PairedComparisons<-function(x,nys){

    # DATAFRAME. x = the data frame, y variables in the left-most columns
	# INTEGER. nys = the number of y variables
	
	# EXAMPLE PairedComparisons(test,4)
	
    require(randomForest,quietly=TRUE)
    namesx<-names(x)
    crs<-new.env()
	crv<-new.env()
    xlen<-ncol(x)
    crs$dataset<-x
    size<-xlen-nys
    mtrx<-matrix(nrow=size,ncol=size)
    xstart<-nys+1
    xend<-xlen-1
	namesseq<-seq(from=nys+1,to=xlen)
    dimnames(mtrx)=list(namesx[namesseq],namesx[namesseq])
    #prepare loop
    yrng<-seq(1:nys)
    xrng<-seq(from=xstart,to=xlen)
    xrng2<-seq(from=xstart,to=xend)
    results<-NULL
    
    for(i in yrng)
    {
        filename<-paste("matrix_",namesx[i],".csv",collapse='')
        for(j in xrng)
        {
            #get 1 variable
            crs$numeric<-c(namesx[j])
            crs$input<-c(namesx[j])
            #omit vector
            varomit<-c(-1*i,-1*j)
            crs$categoric <- NULL
            crs$target<-namesx[i]
            crs$nobs<-nrow(crs$dataset)
            crs$risk<-NULL
            crs$indent<-NULL
            crs$ignore<-namesx[varomit]
            crs$weights<-NULL
            set.seed(crv$seed)
            formula<-paste(namesx[i]," ~ .")
            crs$rf<-randomForest(as.formula(formula),data=crs$dataset[,c(crs$input, crs$target)],ntree=500,mtry=1,importance=TRUE,na.action=na.roughfix,replace=FALSE)
            pvar<-as.character(100*crs$rf$rsq[500])
            mtrx[j-nys,j-nys]<-round(100*crs$rf$rsq[500],digits=2)
        }
        #rest of matrix
        #range for first element of pair
        for(m in xrng2)
        {
            #range for second element of pair
            xrng3<-seq(from=m+1,to=xlen)
            for(k in xrng3)
            {
                #get 2 variables
                crs$numeric<-c(namesx[m],namesx[k])
                crs$input<-c(namesx[m],namesx[k])
                #omit vector
                varomit<-c(-1*i,-1*m,-1*k)
                crs$categoric <- NULL
                crs$target<-namesx[i]
                crs$nobs<-nrow(crs$dataset)
                crs$risk<-NULL
                crs$indent<-NULL
                crs$ignore<-namesx[varomit]
                crs$weights<-NULL
                set.seed(crv$seed)
                formula<-paste(namesx[i]," ~ .")
                crs$rf<-randomForest(as.formula(formula),data=crs$dataset[,c(crs$input, crs$target)],ntree=500,mtry=1,importance=TRUE,na.action=na.roughfix,replace=FALSE)
                mtrx[m-nys,k-nys]<-round(100*crs$rf$rsq[500],digits=2)
                mtrx[k-nys,m-nys]<-round(100*crs$rf$rsq[500],digits=2)
            }
            
            
        }
        write.csv(mtrx,'tmp/paired_comparisons.csv')
    }

}
