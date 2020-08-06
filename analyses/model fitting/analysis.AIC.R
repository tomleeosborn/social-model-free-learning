
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
study1.aic <- read_csv('outputs/study_1_fit_AIC_scores.csv')

#clean up

df.study1 <- data.frame(
  sub_id = integer(77*2),
  model = integer(77*2),
  AIC_score = double(77*2)
)

df.study1[1:77,]$sub_id <- study1.aic$sub_id
df.study1[1:77,]$model <- 1
df.study1[1:77,]$AIC_score <- study1.aic$sigma_mf_model

df.study1[78:154,]$sub_id <- study1.aic$sub_id
df.study1[78:154,]$model <- 0 
df.study1[78:154,]$AIC_score <- study1.aic$no_sigma_mf_model

df.study1$model <- factor(df.study1$model, levels = c(1,0), labels = c('Model WITH sigma mf', 'Model WITHOUT sigma mf'))
table(df.study1$model)#confirm that it works 
head(df.study1)


#visualize 
df.study1 %>%
  ggplot(aes(x = AIC_score, fill = model)) +
  geom_histogram( color="#e9ecef", alpha=0.8, position = 'identity', binwidth = 1) + 
  scale_fill_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  labs(fill = "Model:",
       x = "AIC scores",
       y = "Count") + 
  theme(legend.position = 'bottom') 

#psych describe scores

psych::describeBy(df.study1$AIC_score, df.study1$model)

summary(study1.aic$sigma_mf_model)
summary(study1.aic$no_sigma_mf_model)


#STUDY 2
study2.aic <- read_csv('outputs/study_2_fit_AIC_scores.csv')

#clean up

df.study2 <- data.frame(
  sub_id = integer(172*2),
  model = integer(172*2),
  AIC_score = double(172*2)
)

df.study2[1:172,]$sub_id <- study2.aic$sub_id
df.study2[1:172,]$model <- 1
df.study2[1:172,]$AIC_score <- study2.aic$sigma_mf_model

df.study2[173:344,]$sub_id <- study2.aic$sub_id
df.study2[173:344,]$model <- 0 
df.study2[173:344,]$AIC_score <- study2.aic$no_sigma_mf_model

df.study2$model <- factor(df.study2$model, levels = c(1,0), labels = c('Model WITH sigma mf', 'Model WITHOUT sigma mf'))
table(df.study2$model)#confirm that it works 
head(df.study2)


#visualize 
df.study2 %>%
  ggplot(aes(x = AIC_score, fill = model)) +
  geom_histogram( color="#e9ecef", alpha=0.8, position = 'identity', binwidth = 2.5) + 
  scale_fill_manual(values=c("#69b3a2", "#404080")) +
  theme_classic() + 
  labs(fill = "Model:",
       x = "AIC scores",
       y = "Count") + 
  theme(legend.position = 'bottom') 

#psych describe scores

psych::describeBy(df.study2$AIC_score, df.study2$model)

summary(study1.aic$sigma_mf_model)
summary(study1.aic$no_sigma_mf_model)
