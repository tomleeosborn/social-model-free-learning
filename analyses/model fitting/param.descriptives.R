
rm(list = ls())


#load packages
if (!require(devtools)) {install.packages("devtools"); require(devtools)} 
if (!require(tidyverse)) {install.packages("tidyverse"); require(tidyverse)}
if (!require(ggplot2)) {install.packages("ggplot2"); require(ggplot2)} 
if (!require(ggpubr)) {install.packages("ggpubr"); require(ggpubr)} 
#load packages
if (!require(devtools)) {install.packages("devtools"); require(devtools)} 
if (!require(tidyverse)) {install.packages("tidyverse"); require(tidyverse)}
if (!require(ggplot2)) {install.packages("ggplot2"); require(ggplot2)} 
if (!require(ggpubr)) {install.packages("ggpubr"); require(ggpubr)} 
if (!require(boot)) {install.packages("boot"); require(boot)}
if (!require(lme4)) {install.packages("lme4"); require(lme4)} 
if (!require(sjPlot)) {install.packages("sjPlot"); require(sjPlot)} 
if (!require(ggstatsplot)) {install_github("IndrajeetPatil/ggstatsplot");
  require(ggstatsplot)}
if (!require(lmerTest)) {install.packages("lmerTest"); require(lmerTest)} 
if (!require(nlme)) {install.packages("nlme"); require(nlme)}
if (!require(rmarkdown)) {install.packages("rmarkdown"); require(rmarkdown)} 
if (!require(gridExtra)) {install.packages("gridExtra"); require(gridExtra)} 
if (!require(simr)) {install.packages("simr"); require(simr)}
#set working directory to the directory where script is residing 
groupedstats:::set_cwd()



#STUDY 1 
study1.params.SMF <- read_csv('outputs/study_1_fit_params_sigma_mf_model.csv')
summary(study1.params.SMF)

study1.params.NOSMF <- read_csv('outputs/study_1_fit_params_no_sigma_mf_model.csv')
summary(study1.params.NOSMF)


#STUDY 2
study2.params.SMF <- read_csv('outputs/study_2_fit_params_sigma_mf_model.csv')
summary(study2.params.SMF)

study2.params.NOSMF <- read_csv('outputs/study_2_fit_params_no_sigma_mf_model.csv')
summary(study2.params.NOSMF)
2