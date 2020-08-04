# DATA ANALYSIS  FOR PRE-REGISTERED STUDY ON SOCIAL MODEL FREE LEARNING  
# JULY 2020, EMAIL TOMLEEOSBORN@GMAIL.COM

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
if (!require(lmerTest)) {install.packages("lmerTest"); require(lmerTest)} 
if (!require(nlme)) {install.packages("nlme"); require(nlme)}
if (!require(reshape)) {install.packages("reshape"); require(reshape)} 
if (!require(rmarkdown)) {install.packages("rmarkdown"); require(rmarkdown)} 
if (!require(rmarkdown)) {install.packages("effects"); require(effects)} 
if (!require(rmarkdown)) {install.packages("gridExtra"); require(gridExtra)} 
if (!require(MASS)) {install.packages("MASS"); require(MASS)} 


#set working directory to the directory where script is residing 
groupedstats:::set_cwd()

#LOAD DATA
df.daw  <- read_csv('data/osborn_data_cleaned.csv') %>%
  arrange(subject)
demo <- read_csv('data/osborn_social_mf_demo.csv')
df.iri <- read_csv('data/osborn_social_mf_iri.csv')

#Psychometrics of the IR 

iri.full <- df.iri %>%
  dplyr::select(
    iri_1 , iri_2 , iri_3 , iri_4 , iri_5 , iri_6 , iri_7 , iri_8 , iri_9 , iri_10 , 
      iri_11 , iri_12 , iri_13 , iri_14 , iri_15 , iri_16 , iri_17 , iri_18 , iri_19 , iri_20 ,
      iri_21 , iri_22 , iri_23 , iri_24 , iri_25 , iri_26 , iri_27 , iri_28
  )

iri.PT <- df.iri %>%
  dplyr::select(
    iri_3 , iri_8 , iri_11 , iri_15 , iri_21 , iri_25 , iri_28
  )


iri.FS <- df.iri %>%
  dplyr::select(
    iri_1 , iri_5 , iri_7 , iri_12 , iri_16 , iri_23 , iri_26
  )

iri.EC <- df.iri %>%
  dplyr::select(
    iri_2 , iri_4 , iri_9 , iri_14 , iri_18 , iri_20 , iri_22
  )

iri.PD<- df.iri %>%
  dplyr::select(
    iri_6 , iri_10 , iri_13 , iri_17 , iri_19 , iri_24 , iri_27
  )

psych::alpha(iri.full)


#COMBINE DF WITH IRI
df<- merge(df.daw, df.iri, by = "subject")

#SUM UP IRI 
df %>%
  dplyr::mutate(
    IRI_Total = iri_1 + iri_2 + iri_3 + iri_4 + iri_5 + iri_6 + iri_7 + iri_8 + iri_9 + iri_10 + 
      iri_11 + iri_12 + iri_13 + iri_14 + iri_15 + iri_16 + iri_17 + iri_18 + iri_19 + iri_20 +
      iri_21 + iri_22 + iri_23 + iri_24 + iri_25 + iri_26 + iri_27 + iri_28, 
    IRI_PT = iri_3 + iri_8 + iri_11 + iri_15 + iri_21 + iri_25 + iri_28,
    IRI_FS = iri_1 + iri_5 + iri_7 + iri_12 + iri_16 + iri_23 + iri_26,
    IRI_EC = iri_2 + iri_4 + iri_9 + iri_14 + iri_18 + iri_20 + iri_22,
    IRI_PD = iri_6 + iri_10 + iri_13 + iri_17 + iri_19 + iri_24 + iri_27
  ) -> df

#prepare data

#find who went first, participant or social agent
df %>%
  dplyr::group_by(subject)%>%
  dplyr::mutate(
    playing_order = first(current_player)
  ) -> df 

player_first <- df %>%
  filter(playing_order==1)

social_first <- df %>%
  filter(playing_order==2)

#add critical trials 
player_first <- player_first %>% 
  mutate(last.reward = lag(Re)) %>% 
  mutate(last.common = lag(common))%>%
  mutate(last.reward.sign = last.reward>=0)%>% 
  mutate(repeated = Action1==lag(Action1))

social_first <- social_first %>% 
  mutate(last.reward = lag(Re)) %>% 
  mutate(last.common = lag(common))%>%
  mutate(last.reward.sign = last.reward>=0)%>% 
  mutate(repeated = Action1==lag(Action1))

#remove non-social trials 
toDeleteEven <- seq(0, length(player_first$trial_n), 2) #since player went first we delete all even trials
player_first <- player_first[-toDeleteEven,]
player_first <- player_first %>%
  dplyr::filter(trial_n != min(trial_n, na.rm = T))

toDeleteOdd <- seq(1, length(social_first$trial_n), 2)
social_first <- social_first[-toDeleteOdd,]

df.crits <- full_join(player_first, social_first)

df.crits <- df.crits %>%
  dplyr::filter(
    rt1<=4000
  )

#Model 1: Moderating role of IRI (full scale)

df.crits$rewarded <-  df.crits$last.reward- mean (df.crits$last.reward, na.rm = TRUE)
df.crits$common <-  df.crits$common - mean(df.crits$common, na.rm = TRUE)
df.crits$IRI_Total <- df.crits$IRI_Total - mean(df.crits$IRI_Total, na.rm = TRUE)

model1 <- glmer(repeated ~ rewarded * last.common * IRI_Total + 
                  (1 + last.reward * last.common * IRI_Total|subject) + (1 + last.reward * last.common|social_agent_id), 
                data = df.crits,family = binomial) #model failed to converge 

summary(model1)

sjPlot::tab_model(model1, file = 'logreg_moderator.doc')




