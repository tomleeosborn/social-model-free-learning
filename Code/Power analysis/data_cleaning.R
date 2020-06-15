#DATA FOR THIS POWER ANALYSIS FOR PERSON CONDITION DATA FROM OSBORN THESIS
rm(list = ls())

if (!require("sjstats")) {install.packages("sjstats"); require("sjstats")}
if (!require("simr")) {install.packages("simr"); require("simr")}              ## power simulations
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


df <- read_csv('social_learning_study_1.csv') %>%
  arrange(subject)
demo <- read_csv('demo.csv') #demographic information

#CLEAN UP DATA
#Remove players who finished the experiment in greater than 60 minutes //probably doing other things
exclude.subj <- as.character(demo$subject[demo$time_elapsed >3600000])

df %>% #remove these players (15)
  dplyr::filter(
    !(as.character(subject) %in% exclude.subj)
  ) -> df 

#filter out practice trials 
df <- df %>%
  dplyr::filter(practice==0)

#social data 

social_df <- df %>%
  dplyr::filter(
    condition != "single"
  )

social_df %>% #gets us the first playing_order
  dplyr::group_by(subject)%>%
  dplyr::mutate(
    playing_order = first(current_player)
  ) -> social_df

#first filter by whether they went first or second 

social_first <- social_df %>% 
  filter(playing_order==1)

social_second <- social_df %>% 
  filter(playing_order==2)

#mutate social_first 
social_first <- social_first %>% 
  mutate(last.reward = lag(Re)) %>% 
  mutate(last.common = lag(common))%>%
  mutate(last.reward.sign = last.reward>=0)%>% 
  mutate(repeated = Action1==lag(Action1))

social_second <- social_second %>% 
  mutate(last.reward = lag(Re)) %>% 
  mutate(last.common = lag(common))%>%
  mutate(last.reward.sign = last.reward>=0)%>% 
  mutate(repeated = Action1==lag(Action1))


toDeleteEven <- seq(0, length(social_first$trial_n), 2)
social_first <- social_first[-toDeleteEven,]
head(social_first$trial_n, 10) ###confirm it worked, all trial Ns must be even



#Playing order == 2 means that participant went first -> thus we remove all odd trials
toDeleteOdd <- seq(1, length(social_second$trial_n), 2)
social_second <- social_second[-toDeleteOdd,]
head(social_second$trial_n, 10) ###confirm it worked, all trial Ns must be odd

social_df <- full_join(social_first,social_second)

social_df %>% 
  dplyr::filter(
    condition == 'human'
  ) -> person.df


write_csv(person.df, 'person_condition_data.csv')
