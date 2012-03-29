
## require(MCMCpack);

splitParameters<-function(paramList){
  param.fixed=list();
  param.free.init =list();
  param.free.weight =list();
  param.free.lower =list();
  param.free.upper =list();
  for(iter in seq(along=paramList)){
    if(class(paramList[[iter]])!="clineParameter")
      stop(paste("Item",paramList[[iter]],"not a cline parameter!"));
    parName<-attr(paramList[[iter]],"param");
    parValue<-paramList[[iter]]$val;
    
    if(attr(paramList[[iter]],"fixed")){
      param.fixed[[parName]]<-parValue;
    }else{
      param.free.init[[parName]]<-parValue;
      param.free.weight[[parName]]<-paramList[[iter]]$w;
      param.free.lower[[parName]]<-attr(paramList[[iter]],"limit.lower");
      param.free.upper[[parName]]<-attr(paramList[[iter]],"limit.upper");
    }
  }
  param<-list(init=param.free.init,tune=param.free.weight,
              lower=param.free.lower,upper=param.free.upper,
              fixed=param.fixed);
  return(param);
}

## cline.unscale <- function(cline.data, pMin,pMax){

##   cline.data$obsFreq <- (cline.data$obsFreq - pMin)/(pMax-pMin);
##   return(cline.data);
## }

## cline.logit <- function(cline.data){
##   attach(cline.data);
##   cline.data$obsFreq <- log( obsFreq / ( 1- obsFreq));
##   detach();
##   return(cline.data);
## }

## cline.samp.dist <- function(cline.data) {
##   dist.pool <- unique(sort(as.numeric(cline.data$dist)));
##   dist.init= quantile(dist.pool, probs=c(0.25,0.75));
##   potLeftOut=length(dist.pool[dist.pool <= dist.init[[1]]]);
##   potRightOut=length(dist.pool[dist.pool >= dist.init[[2]]])-1;
##   potInner=length(dist.pool[(dist.pool < dist.init[[2]])&(dist.pool > dist.init[[1]])]);
## ##   print(dist.init);
## ##   print(potLeftOut);
## ##   print(potRightOut);
## ##   print(potInner);
##   dist.len<-length(dist.pool);
##   distLeftSeries<-numeric(1);
##   distLeftSeries[1]<-dist.init[[1]];
##   distRightSeries<-numeric(1);
  
##   distRightSeries[1]<-dist.init[[2]];
##   if(potLeftOut>2)  distLeftSeries  <- c(dist.pool[2:potLeftOut],
##                                          distLeftSeries);
##   if(potRightOut>1) distRightSeries <- c(distRightSeries        ,
##                                          dist.pool[(dist.len-potRightOut):(dist.len-1)]);
##   if(potInner > 1) {
##     distLeftSeries  <- c(distLeftSeries,
##                          dist.pool[potLeftOut+1]);
##     distRightSeries <- c(dist.pool[dist.len-potRightOut-1],
##                          distRightSeries);
##   }
##   return(list(unique(distLeftSeries),unique(distRightSeries)));
## }

## cssp<-function(cline.data,do.tail="none",pMinS=NULL,pMaxS=NULL){
##   do.left<-FALSE;
##   do.right<-FALSE;
##   do.mirror<-FALSE;
 
##   keyValues=c("center","width","pMin","pMax")
    
##   attach(cline.data);
##   pOQ<-quantile(unique(sort(obsFreq)),probs=c(0,0.1,0.9,1));
  
##   detach(cline.data);
##   if(is.null(pMinS)){
##     pMinS<-as.numeric(unique(c(0,pOQ[[1]]/2,pOQ[[1]],pOQ[[2]])));
##     if(length(pMaxS)<3) {
##       pMinS<-as.numeric(unique(c(pMinS,(pOQ[[1]]+pOQ[[2]])/2,0.01+pOQ[[2]])));
##     }
##   } else {
##     pMinS<-as.numeric(pMinS);
##     if(length(pMinS)==0) {
##       warning("Malformed pMinS, using 0 instead");
##       pMinS<-as.numeric(c(0));
##     }
##   }
##   if(is.null(pMaxS)){
##     pMaxS<-as.numeric(unique(c(1,(1+pOQ[[4]])/2,pOQ[[4]],pOQ[[3]])));
##     if(length(pMaxS)<3) {
##       pMaxS<-as.numeric(unique(c(pMaxS,(pOQ[[3]]+pOQ[[4]])/2,pOQ[[3]]-0.01)));
##     }
##   } else {
##     pMaxS<-as.numeric(pMaxS);
##     if(length(pMaxS)==0) {
##       warning("Malformed pMaxS, using 1 instead");
##       pMaxS<-as.numeric(c(1));
##     }
##   }
  
##   bothDist<-cline.samp.dist(cline.data);
  
##   if(identical(tolower(do.tail),"mirror")){
##     do.left<-TRUE;
##     do.right<-TRUE;
##     do.mirror<-TRUE;
##     result<-expand.grid(pMin=pMinS,pMax=pMaxS,dist.left=bothDist[[1]],dist.right=bothDist[[2]]);
##     keyValues=c(keyValues,"deltaM","tauM");
##   } else if (identical(tolower(do.tail),"both")) {
##     do.left<-TRUE;
##     do.right<-TRUE;
##     result<-expand.grid(pMin=pMinS,pMax=pMaxS,dist.left=bothDist[[1]],dist.right=bothDist[[2]]);
##     keyValues=c(keyValues,"deltaL","tauL","deltaR","tauR");
##   } else if (identical(tolower(do.tail),"left")) {
##     do.left<-TRUE;
##     result<-expand.grid(pMin=pMinS,pMax=pMaxS,dist.left=bothDist[[1]]);
##     keyValues=c(keyValues,"deltaL","tauL");
##   } else if (identical(tolower(do.tail),"right")) {
##     do.right<-TRUE;
##     result<-expand.grid(pMin=pMinS,pMax=pMaxS,dist.right=bothDist[[2]]);
##     keyValues=c(keyValues,"deltaR","tauR");
##   } else {
##     result<-expand.grid(pMin=pMinS,pMax=pMaxS)
##   }
  
##   nThetas<-dim(result)[[1]];
##   result$center<-numeric(nThetas);
##   result$width <-numeric(nThetas);
##   result$deltaL <-numeric(nThetas);
##   result$tauL <-numeric(nThetas);
##   result$deltaR <-numeric(nThetas);
##   result$tauR <-numeric(nThetas);
##   result$deltaM <-numeric(nThetas);
##   result$tauM <-numeric(nThetas);
##   for(iter in 1:nThetas){
##     tPMin<- result$pMin[[iter]];
##     tPMax<- result$pMax[[iter]];
## ##     myClineData=subset(cline.data,
## ##       (cline.data$obsFreq >tPMin)&
## ##       (cline.data$obsFreq <tPMax));
##     myClineData<-cline.data;
##     myClineData$obsFreq[ myClineData$obsFreq< (1e-4+tPMin) ] <-
##       rep( 1e-4+tPMin , length(which( myClineData$obsFreq< (1e-4+tPMin))));
##     myClineData$obsFreq[ myClineData$obsFreq> (-1e-4+tPMax )]<-
##       rep( tPMax-1e-4 , length(which( myClineData$obsFreq > (tPMax-1e-4)))); #=  0.9999*tPMax ;
## ## print(myClineData);
##     myLogitData<-cline.logit(cline.unscale(myClineData,tPMin,tPMax));
##     myFullLogitData<-myLogitData;
##     if(do.left){
##       myLeftData=subset(myLogitData,myLogitData$dist <= result$dist.left[[iter]]);
##       myLogitData=subset(myLogitData,myLogitData$dist >= result$dist.left[[iter]]);
##     }
##     if(do.right){
##       myRightData=subset(myLogitData,myLogitData$dist >= result$dist.right[[iter]]);
##       myLogitData=subset(myLogitData,myLogitData$dist <= result$dist.right[[iter]]);
##     }
##     lmEst<-NULL;
##     try(lmEst<-lm(obsFreq~dist,data=myLogitData));
##     if(is.null(lmEst)) {
##       try(lmEst<-lm(obsFreq~dist,data=myFullLogitData));
##       if(is.null(lmEst)) {
##         result$width[[iter]]<-NA;
##         next;
##       }
##     }
##     lambda=lmEst$coefficients[[2]]
##     result$width[[iter]]<- abs(0.25/lambda);
##     result$center[[iter]]<- -lmEst$coefficients[[1]]/lmEst$coefficients[[2]];
   
##     if(do.mirror){
##       result$center[[iter]]<- ( result$dist.left[[iter]]+ result$dist.right[[iter]])/2;
##     }
##     if(do.left){
##        if(result$center[[iter]]< result$dist.left[[iter]])
##       result$center[[iter]]=result$dist.left[[iter]];
##       lmEst<-NULL;
##       try(lmEst<-lm(obsFreq~dist,data=myLeftData));
##       if(is.null(lmEst)) {
##         result$tauL[[iter]]<-0; 
##       }else{
##         propose.tau<- lmEst$coefficients[[2]]/lambda;
##         propose.tau=ifelse(propose.tau<0,1e-4+propose.tau*1e-5,propose.tau);
##         propose.tau=ifelse(propose.tau>=1,1+(propose.tau-1)*1e-5-1e-4,propose.tau);
##         propose.tau=ifelse(propose.tau<0,0,propose.tau);
##         propose.tau=ifelse(propose.tau>1,1,propose.tau);
##         result$tauL[[iter]]<-propose.tau;
        
##       }
##       result$deltaL[[iter]]<- result$center[[iter]]- result$dist.left[[iter]];
##     }
##     if(do.right){
      
##     if(result$center[[iter]]> result$dist.right[[iter]])
##       result$center[[iter]]=result$dist.right[[iter]];
    
##       lmEst<-NULL;
##       try(lmEst<-lm(obsFreq~dist,data=myRightData));
##       if(is.null(lmEst)) {
##         result$tauR[[iter]]<-0;
##       }else{
##         propose.tau<- lmEst$coefficients[[2]]/lambda;
##         propose.tau=ifelse(propose.tau<0,1e-4+propose.tau*1e-5,propose.tau);
##         propose.tau=ifelse(propose.tau>=1,1+(propose.tau-1)*1e-5-1e-4,propose.tau);
##         propose.tau=ifelse(propose.tau<0,0,propose.tau);
##         propose.tau=ifelse(propose.tau>1,1,propose.tau);
##         result$tauR[[iter]]<- propose.tau;
##       }
##       result$deltaR[[iter]]<-result$dist.right[[iter]]- result$center[[iter]]
##     }
##     if(do.mirror){
##       tau.mirror=( result$tauL[[iter]]+ result$tauR[[iter]])/2;
##       result$tauR[[iter]]<-tau.mirror;
##       result$tauL[[iter]]<-tau.mirror;
##       result$tauM[[iter]]<-tau.mirror;
##       result$deltaM[[iter]]<- result$deltaL[[iter]]
##     }
    
##   }
  
##   result=result[,keyValues]
##   result=na.omit(result);
##   return(result);
## } 

## ## ## format of the cline model Frame
## ## objCFrame<-list();
## ## objCFrame$meta.model <- objCMeta;
## ## objCFrame$data <-objSampleData;  ##Keep Seperate?
## ## objCFrame$parameters <-objParameterDataFrame;
## ## objCFrame$mcmc <- mcmcObj;
## ## class(objCframe)<-"clineModelFrame";

## getCredibleCut<-function(clineFrame,rejectionPercent=0.05){

## model.LL=clineFrame$allClines$model.LL
##   credibleLLspace<-data.frame(LL=sort(model.LL), percentile=cumsum(exp(sort(model.LL)))/sum(exp(sort(model.LL))));

##   credible.LLcut<-min(subset(credibleLLspace,credibleLLspace$percentile>rejectionPercent)$LL);
## return(credible.LLcut)
## }

## getCredibleCutG<-function(clineDF,rejectionPercent=0.05){

## model.LL=clineDF$model.LL
##   credibleLLspace<-data.frame(LL=sort(model.LL), percentile=cumsum(exp(sort(model.LL)))/sum(exp(sort(model.LL))));

##   credible.LLcut<-min(subset(credibleLLspace,credibleLLspace$percentile>rejectionPercent)$LL);
## return(credible.LLcut)
## }
## getCredibleLLspace<-function(clineFrame){

## model.LL=clineFrame$allClines$model.LL
##   credibleLLspace<-data.frame(LL=sort(model.LL), percentile=cumsum(exp(sort(model.LL)))/sum(exp(sort(model.LL))));

## return(credibleLLspace)
## }

## fitClineModel <- function(model,sampleData, verbose=10000,
##                           burnin=1000,mcmc=1e6,thin=100,
##                           seed=list(NA,1),rejectLL=-1e8){
##   myClineFrame=list(data=sampleData);
## ##  myModel<-model;
##   attr(myClineFrame,"mcmc.count")<-0;
##   if(identical(is.null(seed),TRUE)){
##     seed=list(NA, attr(clineFrame,"mcmc.count")+1)
##   }
##   if(is.list(seed)&&length(seed)>1)
##     attr(myClineFrame,"mcmc.count")<-seed[[2]];
  
##   myParams<-splitParameters(model$parameterTypes);
## ##   param<-list(init=param.free.init,tune=param.free.weight,
## ##               lower=param.free.lower,upper=param.free.upper,
## ##               fixed=param.fixed);
##   oldFormals<-formals(model$func);
##   tttFormals<-oldFormals[names(myParams$init)];
##   names(tttFormals)<-names(myParams$init);
##   formals(model$func)<-c(tttFormals,myParams$fixed);
##   formals(model$req)<-c(tttFormals,myParams$fixed);
##    formals(model$prior)<-c(tttFormals,myParams$fixed);
## ## print(c(tttFormals,myParams$fixed)); 
##   myRejectionLL<-rejectLL;
##   clineLLFunc <- function(theta,meta.model,obsData){
## ##      print("D");
## ##      print(list(theta,meta.model,obsData));
##     if(! do.call(meta.model$req,as.list(theta))) return(myRejectionLL);
##     model=do.call(meta.model$func,as.list(theta));
## thetaLL=do.call(meta.model$prior,as.list(theta));
##     result<-obsData$model.LL(model)+thetaLL;
##     if(identical(is.finite(result),TRUE))
##       return(result);
##     return(myRejectionLL);
##   }
##   VMATRIX<-NULL;
##   pMinS.cssp<-NULL;
##   pMaxS.cssp<-NULL;
##   if(sum(names(myParams$fixed) %in% "pMin")>0) pMinS.cssp<-myParams$fixed$pMin;
##   if(sum(names(myParams$fixed) %in% "pMax")>0) pMaxS.cssp<-myParams$fixed$pMax;
##   sampleModels<-cssp(sampleData$frame,
##                      attr(model,"tails"),
##                      pMinS=NULL,
##                      pMaxS=NULL
##                      )[,names(myParams$init)];
##   if(dim(sampleModels)[[1]]>2){
##     ## print(sampleModels); #Diagnostics
##     sampleModels<-subset(sampleModels,do.call(model$req,as.list(sampleModels[names(myParams$init)])))
##     ## print(sampleModels); #Diagnostics
##     for(iter in seq(dim(sampleModels)[[1]])){
##       sampleModels[iter,"model.LL"] <-
##         clineLLFunc(sampleModels[iter,names(myParams$init)],
##                     model,
##                     sampleData);
##     }
##     ## print(sampleModels);
##     ## print(xyplot(pMin+pMax+tauR~pMin+pMax+tauR|model.LL>-1e9,data=sampleModels))
##     ##  sampleModels<-subset(sampleModels,sampleModels$model.LL>getCredibleCutG(sampleModels,0.005))
##     try(VMATRIX<-cov(sampleModels));
##     if(!identical(is.null(VMATRIX),TRUE)){
##       print(VMATRIX);
##       bounded.param<-lapply(model$parameterTypes[names(myParams$init)],
##                             attr,
##                             "realBTWN01")==TRUE
##       counter.inv<-diag(ifelse(c(bounded.param,FALSE),sign(VMATRIX["model.LL",]),1/(VMATRIX["model.LL",])))
##       ## print(counter.inv);
##       dimnames(counter.inv)<-list(rownames(VMATRIX),colnames(VMATRIX));
##       VMATRIX<-(counter.inv%*%VMATRIX%*%counter.inv)
      
##       VMATRIX<-VMATRIX[names(myParams$init),names(myParams$init)]#/VMATRIX["model.LL","model.LL"];
##     }
##   }
##   print("C");
##    print(VMATRIX);
## ## print(  clineLLFunc (myParams$init,meta.model=model,obsData=sampleData));
## ##  print(list(fun=clineLLFunc, logfun="TRUE",
## ##                  burnin=burnin, mcmc=mcmc, thin=thin,
## ##                  theta.init=myParams$init,
## ##                  tune=myParams$tune,
## ##                  meta.model=model,
## ##                  obsData=sampleData,
## ##                  seed=seed
##              ##     optim.control=list(fnscale = -1, trace = 0,
## ##                    REPORT = 10,maxit = 5000),
## ##                  optim.method= "L-BFGS-B",
## ##                  optim.lower=myParams$lower,
## ##                  optim.upper=myParams$upper
## ##              ))
 
## ##   print(optim(myParams$init, function(ttt) clineLLFunc(ttt,model,sampleData),
## ##               control = list(fnscale = -1, trace = 0, REPORT = 10,maxit = 5000),
## ##             ##lower = myParams$lower, upper =myParams$upper ,
## ##               method =  "SANN", 
## ##             hessian = FALSE));
## ## stop("readyToRun");
##   myClineFrame$mcmc <-
##     MCMCmetrop1R(fun=clineLLFunc, logfun="TRUE",
##                  burnin=burnin, mcmc=mcmc, thin=thin,
##                  theta.init=myParams$init,
##                  tune=myParams$tune,
##                  meta.model=model,
##                  force.samp=TRUE,
##                  obsData=sampleData,
##                  seed=seed,
##                  V=VMATRIX,
##                  verbose=verbose,
##                  optim.control=list(fnscale = -1, trace = 0,
##                    REPORT = 10,maxit = 5000),
##                  optim.method= "L-BFGS-B",
##                  optim.lower=myParams$lower,
##                  optim.upper=myParams$upper);

##   oldParams<-model$parameterTypes;
##   colnames(myClineFrame$mcmc)<-names(myParams$init)
## ##   print(summary(myClineFrame$mcmc));
## ## plot(myClineFrame$mcmc);
##   model.info=as.data.frame(myClineFrame$mcmc);
##   nSamples=length(model.info[[names(myParams$init)[[1]]]]);
##   if(length(myParams$fixed>0)){
##     for(iter in names(myParams$fixed)){
##       model.info[[iter]]=rep(myParams$fixed[[iter]],nSamples);
##     }
##   }
##   for(iter in 1:nSamples){
##     model.info[iter,"model.LL"] <-
##       clineLLFunc(model.info[iter,names(myParams$init)],
##                   model,
##                   sampleData);
##   }
  
##   myClineFrame$model=model;
##   myClineFrame$allClines=model.info;
##   myClineFrame$maxLL=max(model.info$model.LL);
##   myClineFrame$maxLL.theta=subset(model.info,model.info$model.LL==max(model.info$model.LL))[1,];
##    myClineFrame$maxLL.theta<-myClineFrame$maxLL.theta[names( formals(model$func))];
##   myClineFrame$maxLL.cline=do.call(model$func,as.list( myClineFrame$maxLL.theta))
##   class(myClineFrame)<-"clineModelFrame";
##   return(myClineFrame);
## }


## reFitClineFunc<-function(clineFrame,mcmc=1e6, verbose=10000,thin=NULL,
##                          seed=NULL,rejectLL=-1e8){
##   myClineFrame=list(data=clineFrame$data);
##   model<-clineFrame$model;
##   sampleData<-clineFrame$data;
##   attr(myClineFrame,"mcmc.count")<-0; 
##   if(identical(is.null(seed),TRUE)){
##     if(is.numeric(attr(clineFrame,"mcmc.count"))&&
##        length(attr(clineFrame,"mcmc.count")==1)){
##       seed=list(NA, attr(clineFrame,"mcmc.count")+1)
##     } else {
##       seed=list(NA, attr(myClineFrame,"mcmc.count")+1)
##     }
##   }
##   if(is.list(seed)&&length(seed)>1)
##     attr(myClineFrame,"mcmc.count")<-seed[[2]];
##   if(is.null(thin)) thin<-thin(clineFrame$mcmc);
##   for(typeName in names(model$parameterTypes[lapply(model$parameterTypes,attr,"fixed")==FALSE])) #names(clineFrame$maxLL.theta))
##     model$parameterTypes[[typeName]]$val<-
##       weighted.mean(clineFrame$allClines[clineFrame$allClines$model.LL>(clineFrame$maxLL-2),typeName],exp(clineFrame$allClines$model.LL[clineFrame$allClines$model.LL>(clineFrame$maxLL-2)]));

                                        
## ## clineFrame$maxLL.theta[[typeName]][[1]];
  
##   myParams<-splitParameters(model$parameterTypes);

##   oldFormals<-formals(model$func);
##   tttFormals<-oldFormals[names(myParams$init)];
##   names(tttFormals)<-names(myParams$init);
##   formals(model$func)<-c(tttFormals,myParams$fixed);
##   formals(model$req)<-c(tttFormals,myParams$fixed);
##   formals(model$prior)<-c(tttFormals,myParams$fixed);

##   myRejectionLL<-rejectLL;
##   clineLLFunc <- function(theta,meta.model,obsData){
##     if(! do.call(meta.model$req,as.list(theta))) return(myRejectionLL);
##     model=do.call(meta.model$func,as.list(theta));
    
## thetaLL=do.call(meta.model$prior,as.list(theta));
## ##    return(obsData$model.LL(model)+thetaLL);
    
##     result<-obsData$model.LL(model)+thetaLL;
##     if(identical(is.finite(result),TRUE))
##       return(result);
##     return(myRejectionLL);
##   }
##   attach(clineFrame$allClines);
##   credibleLLspace<-data.frame(LL=sort(model.LL), percentile=cumsum(exp(sort(model.LL)))/sum(exp(sort(model.LL))));
##   detach(clineFrame$allClines);
##   credible.LLcut<-min(subset(credibleLLspace,credibleLLspace$percentile>0.05)$LL);
##  ## VMATRIX<-cov.wt(subset(clineFrame$allClines,clineFrame$allClines$model.LL>=clineFrame$maxLL-8)[,c(names(myParams$init),"model.LL")],wt=exp(clineFrame$allClines$model.LL[clineFrame$allClines$model.LL>=(clineFrame$maxLL-8)]))$cov;
## ## tan , cos/sinc  etc...
##   tune.clines<-(subset(clineFrame$allClines,
##                       clineFrame$allClines$model.LL>=clineFrame$maxLL-4
##                       )[,c(names(myParams$init),"model.LL")])
##   bounded.param<-lapply(model$parameterTypes[names(myParams$init)],
##                               attr,
##                               "realBTWN01")==TRUE
##   ## tune.clines[,bounded.param]<-tan( (tune.clines[,bounded.param]-0.5))
##   ##VMATRIX<-cov.wt(tune.clines,wt=exp(tune.clines$model.LL))$cov;
## VMATRIX<-cov(tune.clines)
##   print(VMATRIX);
##   ## print(bounded.param)
##   ##VMATRIX<-cov(subset(clineFrame$allClines,clineFrame$allClines$model.LL>=clineFrame$maxLL-8)[,c(names(myParams$init),"model.LL")]);
##   ## counter.inv<-diag(ifelse(c(bounded.param,FALSE),rep(1,nrow(VMATRIX)),(abs(VMATRIX["model.LL",])^0.5)/(VMATRIX["model.LL",])))
##   counter.inv<-diag(ifelse(c(bounded.param,FALSE),sign(VMATRIX["model.LL",]),1/(VMATRIX["model.LL",])))
##   ## print(counter.inv);
##   dimnames(counter.inv)<-list(rownames(VMATRIX),colnames(VMATRIX));
##   VMATRIX<-(counter.inv%*%VMATRIX%*%counter.inv)
## ## print(VMATRIX);
##   VMATRIX<-VMATRIX[names(myParams$init),names(myParams$init)]/VMATRIX["model.LL","model.LL"];
  
##   ##counter.bounds<-diag(VMATRIX["model.LL",])
## ## counter.bounds<-diag(ifelse( lapply(model$parameterTypes[rownames(VMATRIX)],attr,"realBTWN01")==TRUE,(0.5+atan(diag(VMATRIX))/3.1)/diag(VMATRIX),1));
## ##   dimnames(counter.bounds)<-list(rownames(VMATRIX),colnames(VMATRIX));
## ##   VMATRIX<-(counter.bounds%*%VMATRIX%*%counter.bounds)
##   print("C");
##    print(VMATRIX);
##  ##  print(list(fun=clineLLFunc, logfun="TRUE",
## ##                  burnin=0, mcmc=mcmc, thin=thin,
## ##                  theta.init=myParams$init,
## ##                  tune=myParams$tune,
## ##                  meta.model=model,
## ##                  force.samp=TRUE,
## ##                  obsData=clineFrame$data,
## ##                  seed=seed,
## ##                  V=VMATRIX,
## ##                  verbose=verbose,
## ##                  optim.control=list(fnscale = -1, trace = 0,
## ##                    REPORT = 10,maxit = 5000),
## ##                  optim.method= "L-BFGS-B",
## ##                  optim.lower=myParams$lower,
## ##                  optim.upper=myParams$upper));
##   myClineFrame$mcmc <-
##     MCMCmetrop1R(fun=clineLLFunc, logfun="TRUE",
##                  burnin=0, mcmc=mcmc, thin=thin,
##                  theta.init=myParams$init,
##                  tune=myParams$tune,
##                  meta.model=model,
##                  force.samp=TRUE,
##                  obsData=sampleData,
##                  seed=seed,
##                  V=VMATRIX,
##                  verbose=verbose,
##                  optim.control=list(fnscale = -1, trace = 0,
##                    REPORT = 10,maxit = 5000),
##                  optim.method= "L-BFGS-B",
##                  optim.lower=myParams$lower,
##                  optim.upper=myParams$upper);

##   oldParams<-model$parameterTypes;
##   colnames(myClineFrame$mcmc)<-names(myParams$init)
##     model.info=as.data.frame(myClineFrame$mcmc);
##   nSamples=length(model.info[[names(myParams$init)[[1]]]]);
##   if(length(myParams$fixed>0)){
##     for(iter in names(myParams$fixed)){
##       model.info[[iter]]=rep(myParams$fixed[[iter]],nSamples);
##     }
##   }
##   for(iter in 1:nSamples){
##     model.info[iter,"model.LL"] <-
##       clineLLFunc(model.info[iter,names(myParams$init)],
##                   model,
##                   myClineFrame$data);
##   }
##   myClineFrame$mcmc.old=clineFrame$mcmc;
##   myClineFrame$mcmc.new=myClineFrame$mcmc;
  
##   if((thin( myClineFrame$mcmc)==thin(clineFrame$mcmc))&
##      (dim( myClineFrame$mcmc)[[2]]==dim(clineFrame$mcmc)[[2]])){
##     myClineFrame$mcmc<-mcmc(rbind(clineFrame$mcmc, myClineFrame$mcmc),
##                             start(clineFrame$mcmc),
##                             end(clineFrame$mcmc)+end(myClineFrame$mcmc),
##                             thin(myClineFrame$mcmc));
##   }else {
##     myClineFrame$mcmc<-mcmc(myClineFrame$mcmc,
##                             start(myClineFrame$mcmc)+ end(clineFrame$mcmc),
##                             end(clineFrame$mcmc)+end(myClineFrame$mcmc),
##                             thin(myClineFrame$mcmc));
##   }
##   myClineFrame$model=model;
##   myClineFrame$allClines.old=clineFrame$allClines;
##   myClineFrame$allClines.new=model.info;
##   myClineFrame$allClines=rbind(clineFrame$allClines,model.info);
##   myClineFrame$maxLL=max( myClineFrame$allClines$model.LL);
##   myClineFrame$maxLL.theta=subset( myClineFrame$allClines, myClineFrame$allClines$model.LL==max( myClineFrame$allClines$model.LL))[1,];
##    myClineFrame$maxLL.theta<-myClineFrame$maxLL.theta[names( formals(model$func))];
##   myClineFrame$maxLL.cline=do.call(model$func,as.list( myClineFrame$maxLL.theta))
##   class(myClineFrame)<-"clineModelFrame";
##   return(myClineFrame);
## }


## ## ## format of the cline Multi Model Frame
## ## objCMMFrame<-list();
## ## objCMMFrame$modelFrames <- list(objCFrame1,objCFrame2);
## ## objCMMFrame$data <-objSampleData;  ##Keep Seperate?
## ## objCMMFrame$parameters <-objParameterDataFrame;  ##Attach to frames?
## ## class(objCMMFrame)<-"clineMultiModelFrame";