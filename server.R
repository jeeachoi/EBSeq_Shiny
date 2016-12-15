library(shiny)
library(shinyFiles)
library(EBSeq)
#library(gdata)
#library(colourpicker)

# Define server logic for slider examples
shinyServer(function(input, output, session) {
  volumes <- c('home'="~")
  shinyDirChoose(input, 'Outdir', roots=volumes, session=session, restrictions=system.file(package='base'))
  output$Dir <- renderPrint({parseDirPath(volumes, input$Outdir)})
  
  ebseqinfo = sessionInfo(package="EBSeq")
  ebseqinfo_print = ebseqinfo$otherPkgs
  
  In <- reactive({
    print(input$Outdir)
    #outdir <- paste0("~", input$Outdir[[1]][[2]], "/")
    outdir <- paste0("~",do.call("file.path",input$Outdir[[1]]),"/")

    print(outdir)
    
    the.file <- input$filename$name
    if(is.null(the.file))stop("Please upload data")
    Sep=strsplit(the.file,split="\\.")[[1]]
    if(Sep[length(Sep)]=="csv")a1=read.csv(input$filename$datapath,stringsAsFactors=F,header=TRUE, row.names=1,comment.char="")
    #if(Sep[length(Sep)]=="xls")a1=read.xls(input$filename$datapath,stringsAsFactors=F,header=TRUE, row.names=1,comment.char="")
    if(Sep[length(Sep)]!="csv") {
      try((a1=read.table(input$filename$datapath,stringsAsFactors=F,header=TRUE, row.names=1,comment.char="")), silent=T)
	  if(!exists("a1")) {
		  print("Initial data import failed, file format may be incorrect. Trying alternate data import...")
        a0=read.table(input$filename$datapath,stringsAsFactors=F,header=TRUE, row.names=NULL,comment.char="")
        a1 <- data.matrix(a0[-1])
        rownames(a1) <- a0[[1]]
      }
    }
    Data=data.matrix(a1)
    
    Group.file <- input$ConditionVector$name
    if(is.null(Group.file))GroupVIn = list(c1=rep(1,ncol(Data)))
    if(!is.null(Group.file)){
      Group.Sep=strsplit(Group.file,split="\\.")[[1]]
      if(Group.Sep[length(Group.Sep)]=="csv")GroupVIn=read.csv(input$ConditionVector$datapath,stringsAsFactors=F,header=F)
      if(Group.Sep[length(Group.Sep)]!="csv")GroupVIn=read.table(input$ConditionVector$datapath,stringsAsFactors=F,header=F, sep="\t")
    }
    GroupV=GroupVIn[[1]]
    if(length(GroupV)!=ncol(Data)) stop("Length of the condition vector is not the same as the number of cells!")
    
    Ig.file <- input$Igvector$name
    if(is.null(Ig.file)) IgV = list(Ig=rownames(Data))
    if(!is.null(Ig.file)){
      Ig.Sep=strsplit(Ig.file,split="\\.")[[1]]
      if(Ig.Sep[length(Ig.Sep)]=="csv")IgVIn=read.csv(input$Igvector$datapath,stringsAsFactors=F,header=F)
      if(Ig.Sep[length(Ig.Sep)]!="csv")IgVIn=read.table(input$Igvector$datapath,stringsAsFactors=F,header=F, sep="\t")
      IgV=IgVIn
      if(length(IgVIn[[1]])!=nrow(Data)) stop("Length of the I_g vector is not the same as the number of genes!")
    }
    
    print(input)
    # Compose data frame
    #input$filename$name
    List <- list(
      Input=the.file,
      GroupFile=Group.file,
      IgFile=Ig.file,
      EMIter=input$EMiter, 
      FDR = input$targetFDR,
      NormTF = ifelse(input$Norm_buttons=="1",TRUE,FALSE), 
      PattInt = input$InterestPatt,
      Cond=factor(GroupV, levels=unique(GroupV)),# follow the order they appeared
      
      Dir=outdir, 
      # For Two-cond
      Out1 = paste0(outdir,input$exDEListSortedbyPPDEwithFDR,".csv"),		
      Out2 = paste0(outdir,input$exDEListSortedbyPPDE,".csv"),
      Out3 = paste0(outdir,input$exOutput,".csv"),  	
      # For Multi-cond
      Out4 = paste0(outdir,input$exMultiPP,".csv"),    
      Out5 = paste0(outdir,input$exMAP,".csv"),    
      # For Both
      Norm = paste0(outdir,input$exNormalized,".csv"),
      Info = paste0(outdir,input$InfoFileName,".txt")
    )

  # normalization     
    if(List$NormTF){
    Sizes <- MedianNorm(Data)
    if(is.na(Sizes[1])){
      Sizes <- MedianNorm(Data, alternative=TRUE)
      message("Alternative normalization method is applied")
    }
    NormData <- GetNormalizedMat(Data,Sizes)
    }
    
    if(!List$NormTF){
      NormData <- Data
    }
	
  # main function - Two conditions
  if(length(unique(GroupV))==2){
    if(!is.null(Ig.file)){
      NgList=GetNg(IgV[[1]], IgV[[2]])
      IsoNgTrun=NgList$IsoformNgTrun
      EBOut=EBTest(Data=Data,NgVector=IsoNgTrun,Conditions=as.factor(GroupV),sizeFactors=Sizes, maxround=List$EMIter, Qtrm=.99, QtrmCut=0) 
    } 
    if(is.null(Ig.file))  EBOut=EBTest(Data=Data,Conditions=as.factor(GroupV),sizeFactors=Sizes, maxround=List$EMIter, Qtrm=.99, QtrmCut=0) 
    PP=GetPP(EBOut)
    PP.sort=sort(PP,decreasing=T)
    PP.sort.FDR=PP.sort[which(PP.sort>=1-as.numeric(List$FDR))]
    
    FC=PostFC(EBOut)
    realFC=FC[[2]]
    postFC=FC[[1]]
    
    Mat=cbind(PP, realFC[names(PP)], postFC[names(PP)],NormData[names(PP),])
    Mat.sort=cbind(PP.sort, realFC[names(PP.sort)], postFC[names(PP.sort)],NormData[names(PP.sort),])
    
    if(length(PP.sort.FDR)>1) Mat.sort.FDR=cbind(PP.sort.FDR, realFC[names(PP.sort.FDR)], postFC[names(PP.sort.FDR)], NormData[names(PP.sort.FDR),])
    if(length(PP.sort.FDR)==1) Mat.sort.FDR=matrix(
      c(PP.sort.FDR, realFC[names(PP.sort.FDR)], postFC[names(PP.sort.FDR)],NormData[names(PP.sort.FDR),])
      ,nrow=1)
    
    colnames(Mat)=colnames(Mat.sort)=c("PPDE","RealFC","PosteriorFC",colnames(NormData))
    if(length(PP.sort.FDR)>0)colnames(Mat.sort.FDR)=c("PPDE","RealFC","PosteriorFC",colnames(NormData))
    write.csv(round(Mat,15),file=List$Out3)  ##cms - made correction on 11/11/13. MORE PRECISION ADDED ON 12-8-14
    write.csv(round(Mat.sort,15),file=List$Out2)
    if(length(PP.sort.FDR)>0)write.csv(round(Mat.sort.FDR,15),file=List$Out1)
    sigout = PP.sort.FDR
  }

  # main function - Multiple conditions
  if(length(unique(GroupV))>2){
      Patt=GetPatterns(as.factor(GroupV))
      if(List$PattInt!="") {
        PattIn = as.numeric(unlist(strsplit(List$PattInt,",")))
        Patt = Patt[PattIn,]      
      }
      Patterns=as.matrix(Patt)

      if(!is.null(Ig.file)){
        NgList=GetNg(IgV[[1]], IgV[[2]])
        IsoNgTrun=NgList$IsoformNgTrun
        EBOut=EBMultiTest(Data=Data,NgVector=IsoNgTrun,Conditions=as.factor(GroupV),
                        AllParti=Patterns,sizeFactors=Sizes, maxround=List$EMIter)
      } 
      if(is.null(Ig.file))  {
        EBOut=EBMultiTest(Data=Data,Conditions=as.factor(GroupV),
                        AllParti=Patterns,sizeFactors=Sizes, maxround=List$EMIter)
      }
      
    PPout=GetMultiPP(EBOut)
    MultiPP=PPout$PP
    MultiMAP=PPout$MAP  
    MultiRealFC=GetMultiFC(EBOut)$FCMat
    MultiPostFC=GetMultiFC(EBOut)$PostFCMat
    
    Mat=cbind(MultiPP, MultiRealFC,MultiPostFC,NormData)
        
    colnames(Mat)=c(colnames(MultiPP),
                    paste0("RealFC-",colnames(MultiRealFC)),
                    paste0("PosteriorFC-",colnames(MultiPostFC)),
                    colnames(NormData))

    write.csv(round(Mat,15),file=List$Out4)  ##cms - made correction on 11/11/13. MORE PRECISION ADDED ON 12-8-14
    
    MapOut = cbind(names(MultiMAP),MultiMAP)
    colnames(MapOut)=c("gene","MAP")
    write.csv(MapOut,file=List$Out5)
    sigout = Mat
  }

  write.csv(NormData, file=List$Norm) #write input 
    
    
    
    ## Sessioninfo & input parameters
    sink(List$Info)
    print(paste0("Package version: ", "EBSeq_",ebseqinfo_print$EBSeq$Version))
    print("Input parameters")
    print(paste0("the number of iteration for EN algorithm? ", List$EMIter))
    print(paste0("whether normalize data? ", List$NormTF))
    print(paste0("Target FDR ", List$FDR))
    #print(paste0("For Multiple conditions: Patterns of interest",Patt))
    sink()
    #sink(file="/tmp/none");sink("/dev/null")
    
    List=c(List, list(Sig=sigout))	
  })   
  
  Act <- eventReactive(input$Submit,{
    In()})
  # Show the values using an HTML table
  output$print0 <- renderText({
    tmp <- Act()
    str(tmp)
    paste("output directory:", tmp$Dir)
  })
  
  output$tab <- renderDataTable({
    tmp <- Act()$Sig
    t1 <- tmp
    print("Done!")
    t1
  },options = list(lengthManu = c(4,4), pageLength = 20))
  

})
