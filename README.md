# EBSeq
EBSeq: An R package for RNA-Seq Differential Expression Analysis https://www.biostat.wisc.edu/~kendzior/EBSEQ/

The latest release version could be found at: http://www.bioconductor.org/packages/devel/bioc/html/EBSeq.html 

EBSeq github page: https://github.com/lengning/EBSeq

### Run the app
To run the WaveCrest graphical user interface (GUI), it requires the following packages: shiny, shinyFiles, EBSeq

R version ≥ 3.0.2 is needed. For mac user, make sure whether xcode is installed.

To install the shiny and EBSeq packages, in R run:

install.packages("shiny")

install.packages("shinyFiles")

install.packages("EBSeq")

To launch EBSeq Shiny GUI, in R run:

> library(shiny)

> library(shinyFiles)

> runGitHub('jeeachoi/EBSeq_Shiny')

![Screenshot](https://github.com/jeeachoi/EBSeq_Shiny/blob/master/EBSeqShiny.png)

## 2. Input files

The first input file should be the expression matrix, with genes in rows and cells as columns. 
Currently, only takes csv files or tab delimited file are accepted.
The input file will be treated as a tab delimited file if the suffix is not '.csv'.

The second input file is the Condition vector. The conditions could be time points, spatial positions, etc. 
It can be csv or tab delimited file. The file should contain 1 column. Each element of the should represent the corresponding condition that each cell belongs to, it should match exactly the order of columns in the expression matrix and be the same length. 

The third input file is the Isoform vector. It can be csv or tab delimited file. The file should contain
1st column with isoform names and 2nd column with gene names. If Isoform vector file is not provided, gene analysis will be performed automatically.

### Example files
An example input file for two-condition gene analysis **GeneMat.csv**, **CondTwo.csv**

An example input file for two-condition Isoform analysis **IsoMat.csv**, **IsoAndGeneNames.csv**, **CondTwo.csv** 

An example input file for multi-condition gene analysis **MultiGeneMat.csv**, **CondMulti.csv**

An example input file for multi-condition Isoform analysis **IsoMultiMat.csv**, **IsoAndGeneNamesMulti.csv**, **IsoMultiCond.csv** 

All the example files can be found at https://github.com/jeeachoi/EBSeq_Shiny/tree/master/example_data   

## 3. Customize options

- Need normalization?: If Yes, normalization using median-by-ratio will be performed prior to the EBSeq run. If the input matrix is already normalized (e.g. by median-by-ratio normalization or TMM), this option should be disabled by selecting No. In addition, if the input expression matrix only contains a small subset of genes, it is suggested to first perform the normalization using all genes before taking the subset

- Patterns of interest: This is used for (gene/isoform) multi-condition analysis only. User can use EBSeqMultiPattern_Shiny (https://github.com/jeeachoi/EBSeq_MultiPattern) to obtain all possible patterns and choose the patterns of interest. If the user is interested in pattern 1,2,3 from the MultiPattern output, type: '1,2,3'. Default will provide result of all possible patterns

- The number of iteration for EM algorithm: Default is 5

- Target FDR: Default is 0.05 (5%). Target FDR will be used to determin DE genes


## 4. Outputs
Four to five files will be generated:
-	normalized.csv: normalized expression matrix with genes in row and cells in column
- info.txt: version information with all input variables are stored

For two-condition analysis:
- DEListSortedbyPPDE_TwoCond.csv: DE genes only (FDR cutoff) sorted by PPDE, followed by Real FC, posterior FC, and normalized expression values
- OutputSortedbyPPDE_TwoCond.csv: Output with sorted gene order by PPDE, followed by Real FC, posterior FC, and normalized expression values
- OutputOrigFileOrder_TwoCond.csv: Output with original gene order from input file, followed by Real FC, posterior FC, and normalized expression values

For multiple-condition analysis:
- OutputPP_MultiCond.csv: Output with posterior probability of being in each pattern, followed by Real FC, posterior FC, and normalized expression values
- OutputMAP_MultiCond.csv: The most likely pattern of each gene

## License
This project is licensed under the terms of the Apache License 2.0

