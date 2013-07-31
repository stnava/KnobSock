library(MASS)
library(hotspots)
library(nortest)
# fnl<-list.files(path="./output",pattern=glob2rx("*corr.txt"),recursive=TRUE)
#
test<-c("DET0000301","DET0008501","DET0010401","DET0011601","DET0013101","DET0014801","DET0025001","DET0030301","DET0000601","DET0008601","DET0010501","DET0011701","DET0013301","DET0014901","DET0026201","DET0035301","DET0000701","DET0008701","DET0010701","DET0012001","DET0013401","DET0015001","DET0026601","DET0042201","DET0007301","DET0009101","DET0010801","DET0012101","DET0013801","DET0015101","DET0026701","DET0042301","DET0007401","DET0009401","DET0010901","DET0012201","DET0014001","DET0015501","DET0027601","DET0042701","DET0007501","DET0009501","DET0011201","DET0012401","DET0014401","DET0019401","DET0029201","DET0043001","DET0007601","DET0009701","DET0011301","DET0012501","DET0014501","DET0020201","DET0029301","DET0043301","DET0007801","DET0010001","DET0011401","DET0012901","DET0014601","DET0021401","DET0029601","DET0044001","DET0008301","DET0010201","DET0011501","DET0013001","DET0014701","DET0024301","DET0029901","DET0044901")

train<-c("DET0000101","DET0002001","DET0003601","DET0004901","DET0006201","DET0014201","DET0028801","DET0042401","DET0000201","DET0002401","DET0003801","DET0005001","DET0006301","DET0015201","DET0029001","DET0042501","DET0000801","DET0002501","DET0003901","DET0005101","DET0006401","DET0015401","DET0030901","DET0042601","DET0001101","DET0002601","DET0004001","DET0005201","DET0006501","DET0015601","DET0035501","DET0043101","DET0001201","DET0002701","DET0004101","DET0005401","DET0007101","DET0016101","DET0037101","DET0043201","DET0001301","DET0002801","DET0004201","DET0005601","DET0008801","DET0021501","DET0039401","DET0044601","DET0001401","DET0003101","DET0004301","DET0005701","DET0008901","DET0021701","DET0039501","DET0001501","DET0003201","DET0004401","DET0005801","DET0009001","DET0024401","DET0040001","DET0001601","DET0003301","DET0004601","DET0005901","DET0009301","DET0026901","DET0040101","DET0001701","DET0003401","DET0004701","DET0006001","DET0010601","DET0028301","DET0040201","DET0001801","DET0003501","DET0004801","DET0006101","DET0014101","DET0028601","DET0042001")
all<-c(test,train)
matres<-matrix( data = rep(NA, 83*length(all) ), nrow=length(all))
rownames(matres)<-all
#####
# par(mfrow=c(10,10))
fn<-paste('performance_hist.jpg',sep='_')
fn<-paste('performance_spiders.jpg',sep='_')
hwf<-250
# jpeg("rplot1.jpg", width = 10 * hwf, height = 10 * hwf)
# pdf(fn)
pvct<-0
pvs<-rep(NA,length(all))
for ( ct in 1:length(all) ) {
  img<-all[ct]
  tt<-paste("./output/ants_",img,"_*/ants_corr.txt",sep='')
  myd<-Sys.glob(tt)
  myc<-rep(NA,length(myd))   
  for ( x in 1:length(myd) ) myc[x]<-max( read.csv(myd[x]),na.rm=T )
  heartCorr<-myc # read.csv('data/LabelMyHeartCorrs.csv')$Corr
  heartCorr[ abs(heartCorr) == Inf ]<-NA
  matres[ct,]<-heartCorr
#  hist(heartCorr, freq = TRUE, col = "lightblue")
#  lines(density(heartCorr,na.rm=T),col='red')
#  ole<-outliers(heartCorr)#,distribution='normal')
#  relthresh<-( median(heartCorr,na.rm=T) - 1.0 * ole$rrms )
#  print( sum( heartCorr<relthresh ,na.rm=T) / length(heartCorr )*100 )
  pv<-sf.test(heartCorr)$p.value
  pvs[ct]<-pv
  print( paste(img,ct, pv, length(myc) ))
  if ( pv < 0.05 ) pvct<-pvct+1
#  lines(density(heartCorr[heartCorr<relthresh] ,na.rm=T),col='blue')
  if ( ct < 101 )
    {
      tit<-paste(img,": OL p-value",pv)
#      hist(heartCorr, freq = TRUE, col = "lightblue", main=tit)
#      lines(density(heartCorr,na.rm=T),col='red')
    }
}
#dev.off()
print( pvct / length(all )*100 )
#
# print( pvct / length(all )*100 )
# [1] 23.87097
#
labs<-c(paste("E",c(1:length(test))),paste("R",c(1:length(train))))
sublabs<-labs
sublabs[ (1:(length(labs)/2))*2 ]<-NA
#pdf('spider_CAP.pdf')
# palette(rainbow(12, s = 0.6, v = 0.75))
stars(matres,draw.segments = TRUE,main='CAP Performance Variation',labels=sublabs,full=F)
# stars(matres,draw.segments = TRUE,frame.plot=TRUE,scale = TRUE, radius  =  FALSE,main='Performance Variation')
#dev.off()
#
# > sum(p.adjust(pvs,method='BH') < 0.05 )
# [1] 21
# a minimum of 13.54839 % had a highly non-gaussian similarity distribution 
#


a<-read.csv('./data/similarityMeasuresCC.csv')
n<-3 ; a[(46*(n-1)+1):(46*(n)),]
amat<-matrix(a[,2],nrow=46)
amat<-amat[1:44,]
pdf('figs/diencephalon_perf.pdf')
stars( t(amat),draw.segments = TRUE,main='Diencephalon Performance Variation',full=F)
dev.off()
pvs<-rep( NA, ncol(amat) )
for ( r in 1:ncol(amat) )
  {
  mm<-amat[,r]
  mm<-mm[1:( length(mm) - 2 ) ]
  pvs[r]<-sf.test(mm)$p.value
#  hist( mm )
#  print( sf.test(mm) )
  }
print( sum( p.adjust( pvs , method='BH')  < 0.05 ) )


