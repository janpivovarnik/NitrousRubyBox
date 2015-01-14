PairedComparisonsGrp<-function(x,nys,seq_grp,seq_names){

    # DATAFRAME. x = the data frame, y variables in the left-most columns
	# INTEGER. nys = the number of y variables
	# LIST. seq_grp = list of column number sequences IDing which columns to group together for the comparison
	# VECTOR. seq_names = list of names for the groups, same length as seq_grp (example below has length of 4)
	
        # EXAMPLE PairedComparisonsGrp(test,4, list(seq(from=5,to=8),seq(from=9,to=14),seq(from=15,to=23),seq(from=24,to=25),
        #  seq(from=26,to=35)),c("externalities","spend","brand","seasons","pricing"))
	
    require(randomForest,quietly=TRUE)
    namesx<-names(x)
    crs<-new.env()
	crv<-new.env()
    xlen<-length(seq_grp) #ncol(x)
    crs$dataset<-x
    size<-xlen #-nys
    mtrx<-matrix(nrow=size,ncol=size)
    xstart<-nys+1
    xend<-xlen-1

	namesseq<-seq(from=1,to=xlen)
    dimnames(mtrx)=list(seq_names[namesseq],seq_names[namesseq])
    
    #prepare loop
    yrng<-seq(1:nys)
    xrng<-seq(from=xstart,to=xlen)
    xrng2<-seq(from=xstart,to=xend)
    results<-NULL

    for(i in yrng)
    {
        filename<-paste("matrix_",namesx[i],".csv",collapse='')
        for(j in 1:xlen)
        {
            #get 1 variable
            crs$numeric<-c(namesx[seq_grp[[j]]])
            crs$input<-c(namesx[seq_grp[[j]]])
            #omit vector
            varomit<-c(-1*i,-1*seq_grp[[j]])
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
            mtrx[j,j]<-round(100*crs$rf$rsq[500],digits=2)
        }
        	
        for(m in 1:xend)
        {
            xrng3<-seq(from=m+1,to=xlen)
            for(k in xrng3)
            {
                #get 2 variables
                crs$numeric<-c(namesx[seq_grp[[m]]],namesx[seq_grp[[k]]])
                crs$input<-c(namesx[seq_grp[[m]]],namesx[seq_grp[[k]]])
                #omit vector
                varomit<-c(-1*i,-1*seq_grp[[m]],-1*seq_grp[[k]])
                crs$categoric <- NULL
                crs$target<-namesx[i]
                crs$nobs<-nrow(crs$dataset)
                crs$risk<-NULL
                crs$indent<-NULL
                crs$ignore<-namesx[varomit]
                crs$weights<-NULL
                set.seed(crv$seed)
                formula<-paste(namesx[i]," ~ .")
                crs$rf<-randomForest(as.formula(formula),data=crs$dataset[,c(crs$input, crs$target)],ntree=500,mtry=2,importance=TRUE,na.action=na.roughfix,replace=FALSE)
                mtrx[m,k]<-round(100*crs$rf$rsq[500],digits=2)
                mtrx[k,m]<-round(100*crs$rf$rsq[500],digits=2)
            }
            
            
        }
       write.csv(mtrx,'tmp/paired_comparisons_grp.csv')
    }
}
