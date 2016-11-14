library(shiny)
library(shinyFiles)
#library(gdata)
options(shiny.maxRequestSize=500*1024^2) 
# Define UI for slider demo application
shinyUI(pageWithSidebar(
  #  Application title
  headerPanel("EBSeq-two/multiple conditions"),
  
  # Sidebar with sliders that demonstrate various available options
  sidebarPanel(width=12,height=20,
               # file
               fileInput("filename", label = "Data file input (support .csv, .txt, .tab)"),
               
               # grouping vector
               fileInput("ConditionVector", label = "Condition vector \n file name (support .csv, .txt, .tab)"),
               
               # I_g vector for isoform
               fileInput("Igvector", label = "I_g vector for isoform analysis \n file name (support .csv, .txt, .tab) - Gene analysis will be applied if I_g vector is not provided"),
               
               column(4,
                      # Normalization
                      radioButtons("Norm_buttons",
                                   label = "Do you need to normalize data?",
                                   choices = list("Yes" = 1,
                                                  "No" = 2),
                                   selected = 1),
                      # patterns of interest
                      textInput("InterestPatt", 
                                label="Patterns of interest for - comma delimited (e.g. if you're interested in pattern 1,2,3 from the MultiPattern output, type: '1,2,3'. Default is all possible patterns.)", 
                                value = ""),
                      # Num EM
                      numericInput("EMiter",
                                   label = "The number of iteration for EM",
                                   value = 5),
                      # targer FDR
                      numericInput("targetFDR",
                                   label = "Target FDR",
                                   value = 0.05)
                      
               ),

               column(4,
                      # output dir
                      tags$div(tags$b("Please select a folder for output :")),
                      
                      shinyDirButton('Outdir', label ='Select Output Folder', title = 'Please select a folder'),
                      tags$br(),
                      tags$br(),
                      
                      # export DE gene list with p-value 
                      textInput("exDEListSortedbyPPDEwithFDR", 
                                label = "Export file name - DE genes only (FDR cutoff) sorted by PPDE", 
                                value = "DEListSortedbyPPDE_TwoCond"),  
                      
                      # export DE gene list with p-value 
                      textInput("exDEListSortedbyPPDE", 
                                label = "Export file name for two conditions - Output with sorted gene order by PPDE", 
                                value = "OutputSortedbyPPDE_TwoCond"),
                      
                      # export DE gene list with p-value 
                      textInput("exOutput", 
                                label = "Export file name for two conditions - Output with original gene order from input file", 
                                value = "OutputOrigFileOrder_TwoCond")
               ),
               column(4,
                      # PP of being in each pattern for every gene
                      textInput("exMultiPP", 
                                label = "Export file name for multiple conditions - Output with posterior probability of being in each pattern", 
                                value = "OutputPP_MultiCond"),
                      
                      # posterior probability of being in each pattern for every gene  
                      textInput("exMAP", 
                                label = "Export file name for multiple conditions - The most likely pattern of each gene", 
                                value = "OutputMAP_MultiCond"),
                      
                      # export normalzied matrix 
                      textInput("exNormalized", 
                                label = "Export file name - normalized expression matrix", 
                                value = "Normalized"),
                      # Info
                      textInput("InfoFileName", 
                                label = "Export file name - Session Info", 
                                value = "Info")
               ),
               br(),
               actionButton("Submit","Submit for processing")
  ),
  # Show a table summarizing the values entered
  mainPanel(
    h4(textOutput("print0")),
    #tableOutput("values")
    dataTableOutput("tab")
  )
))
