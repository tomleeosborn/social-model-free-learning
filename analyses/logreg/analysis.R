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


#helper functions
se <- function(x) {sd(x) / sqrt(length(x))};
dodge <- position_dodge(width=0.9)


#STUDY 2 
df.study2  <- read_csv('../../data/cleaned/study2_full_data_cleaned.csv') %>%
  arrange(subject)
demo.study2 <- read_csv('../../data/cleaned/study2_participant_demo.csv')

#SAMPLE CHARACTERISTICS 
head(demo.study2,5)
table(demo.study2$sex)
psych::describe(demo.study2$age)
psych::describe(demo.study2$bonus)

#PRIMARY OUTCOME: MAIN EFFECT FOR REWARD 

#prepare data
df.study2.crits <- df.study2 %>% 
  dplyr::mutate(
    social_turn = current_player == 2
  )%>%
  dplyr::mutate(
    last.common = lag(common), 
    last.common.fac = factor(last.common, c(1,0), c('Common','Rare')),
    stay = Action1==lag(Action1),
    stay.fac = factor(stay, c(T,F), c('Same action1', 'Different action1')),
    rewarded = lag(Re),
    rewarded.fac = factor(rewarded>0, c(T,F), c("+ive reward", "-ive reward"))
  ) %>%
  filter(trial_n != min(trial_n, na.rm=TRUE)) %>%
  filter(social_turn==FALSE)  



#REMOVE OUTLIER trials
df.study2.crits <- df.study2.crits %>%
  dplyr::filter(
    rt1<=2000
  )

df.study2.crits <- df.study2.crits %>%
  dplyr::filter(
    rt2<=2000
  )

df.study2.bysubj <- df.study2.crits %>% 
  na.omit() %>%
  dplyr::group_by(
    rewarded.fac, last.common.fac, subject
  ) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE)
  )

df.study2.agg <- df.study2.bysubj %>%
  dplyr::group_by(last.common.fac, rewarded.fac) %>%
  dplyr::summarise(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = se(prob.stay)
  )



##NOW BUILD A MIXED EFFECT MODEL
#recenter variables 

df.study2.crits$rewarded <- df.study2.crits$rewarded - mean(df.study2.crits$rewarded, na.rm = TRUE)
df.study2.crits$last.common <- df.study2.crits$common - mean(df.study2.crits$common, na.rm  = TRUE)
df.study2.crits$repeated <- df.study2.crits$stay

model.study2 <- glmer(repeated ~ rewarded *last.common +
                  (1 + rewarded  *last.common|subject) + (1 + rewarded  *last.common|social_agent_id), 
                data = df.study2.crits,family = binomial) #model failed to converge


summary(model.study2)

sjPlot::tab_model(model.study2,file = 'outputs/study2_main_logreg.doc')
