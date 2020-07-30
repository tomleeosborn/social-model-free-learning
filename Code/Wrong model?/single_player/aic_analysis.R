
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



#LOAD DATA

df.wrong_model <- read_csv('AIC_wrong_model.csv')
df.correct.model <- read_csv('AIC_correct_model.csv')

#described 

psych::describe(df.wrong_model$AIC)
psych::describe(df.correct.model$AIC)

#t.test
t.test(df.correct.model$AIC, df.wrong_model$AIC)


#DATA FROM WRONG MODEL

df2.wrong_model <- read_csv('AIC2_wrong_model.csv')
df2.correct.model <- read_csv('AIC2_correct_model.csv')

#described 

psych::describe(df2.wrong_model$AIC)
psych::describe(df2.correct.model$AIC)

#t.test
t.test(df2.correct.model$AIC, df2.wrong_model$AIC)
