
#------------------------------------------------------------------------------#
######## cleaning up environment 
rm(list = ls())

#set seed 
set.seed(102)

#load packages
if (!require(devtools)) {install.packages("devtools"); require(devtools)} 
if (!require(tidyverse)) {install.packages("tidyverse"); require(tidyverse)}
if (!require(ggplot2)) {install.packages("ggplot2"); require(ggplot2)} 
if (!require(psych)) {install.packages("psych"); require(psych)}
if (!require(boot)) {install.packages("boot"); require(boot)}
if (!require(lme4)) {install.packages("lme4"); require(lme4)} 
if (!require(ggstatsplot)) {install_github("IndrajeetPatil/ggstatsplot");
  require(ggstatsplot)}

#clean up data

groupedstats:::set_cwd()

#load dota

df <- read_csv('data/osborn_social_mf_data.csv')
demo <- read_csv('data/osborn_social_mf_demo.csv')

#CLEAN DATA 
#remove those who took >60 minutes on task
exclude.subj <- as.character(demo$subject[demo$time_elapsed >3600000])

df %>% #remove these players (4)
  dplyr::filter(
    !(as.character(subject) %in% exclude.subj)
  ) -> df

#filter out practice trials 
df <- df %>%
  dplyr::filter(practice==0)

#fix bug in data watching trials
df$Action1[df$current_player==2] <- df$agent_Action1[df$current_player==2]
df$S2[df$current_player==2] <- df$agent_S2[df$current_player==2] 

write_csv(df, 'data/osborn_data_cleaned.csv')

