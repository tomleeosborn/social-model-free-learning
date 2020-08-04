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
df  <- read_csv('data/osborn_data_cleaned.csv') %>%
  arrange(subject)
demo <- read_csv('data/osborn_social_mf_demo.csv')


#SAMPLE CHARACTERISTICS 
head(demo,5)
table(demo$sex)
psych::describe(demo$age)
psych::describe(demo$bonus)

#PRIMARY OUTCOME: MAIN EFFECT FOR REWARD 

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


#REMOVE OUTLIER trials

df.crits <- df.crits %>%
  dplyr::filter(
    rt1<=4000
  )#only 30 trials removed


#VISUALIZE 

# relevel to ease visualization 
df.crits$common.fac <- factor(df.crits$common, levels = c(0,1), 
                              labels = c('Rare','Common'))
df.crits$common.fac <- relevel(df.crits$common.fac, ref = "Common")

df.crits$rewarded.fac <- factor(df.crits$last.reward.sign,levels = c(F,T), 
                          labels = c("Punished","Rewarded"))
df.crits$rewarded.fac <- relevel(df.crits$rewarded.fac, ref = "Rewarded")

  

df.bysubj <- df.crits %>% 
  na.omit() %>%
  dplyr::group_by(rewarded.fac, common.fac, subject) %>%
  dplyr::summarize(
    prob.stay = mean(repeated, na.rm = TRUE)
  )

df.agg <- df.bysubj %>%
  dplyr::group_by(common.fac, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )

#plot
ggplot(df.agg, aes(x=rewarded.fac, y = prob.stay.mean,fill = common.fac)) +
  geom_bar(
    stat = 'identity',
    position = position_dodge(width = .9),
    width = .9
  ) +
  geom_errorbar(
    aes(ymin = prob.stay.mean - prob.stay.se, ymax = prob.stay.mean + prob.stay.se),
    width = .2,
    position = position_dodge(width = .9)
  ) + 
  theme(legend.text = element_blank(), legend.title = element_blank(), legend.position = 'none',
        plot.title = element_text(hjust=0.5, size = 14), 
        panel.border = element_rect(colour = "black", fill = NA, size = 2),
        panel.background = element_rect(colour = "white", fill = NA)) +
  scale_fill_manual(values = c("Common" = "#C02739", "Rare" = "#29C7AC")) +
  coord_cartesian(ylim=c(0,.6)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = '',
       title = 'Stay probability after social trials')




##NOW BUILD A MIXED EFFECT MODEL
model1 <- glmer(repeated ~ last.reward *last.common +
                  (1 + last.reward *last.common|subject) + (1 + last.reward *last.common|social_agent_id), 
                data = df.crits,family = binomial) #model failed to converge


summary(model1)

sjPlot::tab_model(model1,file = 'logreg.doc')
