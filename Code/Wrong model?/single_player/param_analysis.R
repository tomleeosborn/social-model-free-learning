
rm(list = ls())


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

#set working directory to the directory where script is residing 
groupedstats:::set_cwd()


#wrong model
df.actual <- read_csv('df.agents_wrong_params.csv')
df.fit <- read_csv('fit_agent_wrong.csv')

cor(df.actual$w_MB, df.fit$w_MB)

#wrong model
df.actual <- read_csv('df.agents_correct_params.csv')
df.fit <- read_csv('fit_agent_correct.csv')

cor(df.actual$w_MB, df.fit$w_MB)

