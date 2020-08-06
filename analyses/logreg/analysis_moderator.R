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
df.study2.daw  <- read_csv('../../data/cleaned/study2_full_data_cleaned.csv') %>%
  arrange(subject)
demo.study2 <- read_csv('../../data/cleaned/study2_participant_demo.csv')
df.study2.iri <- read_csv('../../data/cleaned/study2_iri_data.csv')

#reverse score items
df.study2.iri$iri_3 <- 4 - df.study2.iri$iri_3 
df.study2.iri$iri_4 <- 4 - df.study2.iri$iri_4 
df.study2.iri$iri_7 <- 4 - df.study2.iri$iri_7 
df.study2.iri$iri_12 <- 4 - df.study2.iri$iri_12 
df.study2.iri$iri_13 <- 4 - df.study2.iri$iri_13 
df.study2.iri$iri_14 <- 4 - df.study2.iri$iri_14 
df.study2.iri$iri_15 <- 4 - df.study2.iri$iri_15 
df.study2.iri$iri_19 <- 4 - df.study2.iri$iri_19 

#Psychometrics of the IR 

iri.full <- df.study2.iri %>%
  dplyr::select(
    iri_1 , iri_2 , iri_3 , iri_4 , iri_5 , iri_6 , iri_7 , iri_8 , iri_9 , iri_10 , 
      iri_11 , iri_12 , iri_13 , iri_14 , iri_15 , iri_16 , iri_17 , iri_18 , iri_19 , iri_20 ,
      iri_21 , iri_22 , iri_23 , iri_24 , iri_25 , iri_26 , iri_27 , iri_28
  )

iri.PT <- df.study2.iri %>%
  dplyr::select(
    iri_3 , iri_8 , iri_11 , iri_15 , iri_21 , iri_25 , iri_28
  )


iri.FS <-df.study2.iri %>%
  dplyr::select(
    iri_1 , iri_5 , iri_7 , iri_12 , iri_16 , iri_23 , iri_26
  )

iri.EC <- df.study2.iri%>%
  dplyr::select(
    iri_2 , iri_4 , iri_9 , iri_14 , iri_18 , iri_20 , iri_22
  )

iri.PD<- df.study2.iri%>%
  dplyr::select(
    iri_6 , iri_10 , iri_13 , iri_17 , iri_19 , iri_24 , iri_27
  )

psych::alpha(iri.full)$total$std.alpha
psych::alpha(iri.PT)$total$std.alpha
psych::alpha(iri.PD)$total$std.alpha
psych::alpha(iri.EC)$total$std.alpha
psych::alpha(iri.FS)$total$std.alpha

#COMBINE DF WITH IRI
df.study2 <- merge(df.study2.daw, df.study2.iri, by = "subject")

#SUM UP IRI 
df.study2 %>%
  dplyr::mutate(
    IRI_Total = iri_1 + iri_2 + iri_3 + iri_4 + iri_5 + iri_6 + iri_7 + iri_8 + iri_9 + iri_10 + 
      iri_11 + iri_12 + iri_13 + iri_14 + iri_15 + iri_16 + iri_17 + iri_18 + iri_19 + iri_20 +
      iri_21 + iri_22 + iri_23 + iri_24 + iri_25 + iri_26 + iri_27 + iri_28, 
    IRI_PT = iri_3 + iri_8 + iri_11 + iri_15 + iri_21 + iri_25 + iri_28,
    IRI_FS = iri_1 + iri_5 + iri_7 + iri_12 + iri_16 + iri_23 + iri_26,
    IRI_EC = iri_2 + iri_4 + iri_9 + iri_14 + iri_18 + iri_20 + iri_22,
    IRI_PD = iri_6 + iri_10 + iri_13 + iri_17 + iri_19 + iri_24 + iri_27
  ) -> df.study2

#get criticial trials 
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
#plot
ggplot(df.study2.agg, aes(x=rewarded.fac, y = prob.stay.mean,fill = last.common.fac)) +
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
  theme(legend.position = 'bottom',
        plot.title = element_text(hjust=0.5, size = 14), 
        panel.border = element_rect(colour = "black", fill = NA, size = 2),
        panel.background = element_rect(colour = "white", fill = NA)) +
  scale_fill_manual(values = c("Common" = "#69b3a2", "Rare" = "#404080")) + 
  coord_cartesian(ylim=c(0,.7)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = '',
       title = 'Stay probability after social trials (Study 2)')


#plot scatterplot of IRI scores and stay prob
df.study2.IRI.bysubj <- df.study2.crits %>% 
  na.omit() %>%
  dplyr::group_by(
    subject
  ) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE),
    IRI.total = mean(IRI_Total,na.rm = TRUE),
    IRI.PD = mean(IRI_PD,na.rm = TRUE),
    IRI.PT = mean(IRI_PT,na.rm = TRUE),
    IRI.EC = mean(IRI_EC,na.rm = TRUE),
    IRI.FS = mean(IRI_FS,na.rm = TRUE)
  )

ggplot(df.study2.IRI.bysubj, aes(x=IRI.total, y=prob.stay)) + 
  geom_point(color = "#404080") + 
  theme(legend.position = 'bottom',
        plot.title = element_text(hjust=0.5, size = 14), 
        panel.border = element_rect(colour = "black", fill = NA, size = 2),
        panel.background = element_rect(colour = "white", fill = NA)) +
  theme_classic()-> plot.1

ggplot(df.study2.IRI.bysubj, aes(x=IRI.PD, y=prob.stay)) + 
  geom_point(color = "#03254c") + 
  theme(legend.position = 'bottom',
        plot.title = element_text(hjust=0.5, size = 14), 
        panel.border = element_rect(colour = "black", fill = NA, size = 2),
        panel.background = element_rect(colour = "white", fill = NA)) +
  theme_classic()-> plot.2


ggplot(df.study2.IRI.bysubj, aes(x=IRI.PT, y=prob.stay)) + 
  geom_point(color = "#03254c")+ 
  theme(legend.position = 'bottom',
        plot.title = element_text(hjust=0.5, size = 14), 
        panel.border = element_rect(colour = "black", fill = NA, size = 2),
        panel.background = element_rect(colour = "white", fill = NA)) +
  theme_classic()-> plot.3


ggplot(df.study2.IRI.bysubj, aes(x=IRI.FS, y=prob.stay)) + 
  geom_point(color = "#03254c") + 
  theme(legend.position = 'bottom',
        plot.title = element_text(hjust=0.5, size = 14), 
        panel.border = element_rect(colour = "black", fill = NA, size = 2),
        panel.background = element_rect(colour = "white", fill = NA)) +
  theme_classic()-> plot.4


ggplot(df.study2.IRI.bysubj, aes(x=IRI.EC, y=prob.stay)) + 
  geom_point(color = "#03254c") + 
  theme(legend.position = 'bottom',
        plot.title = element_text(hjust=0.5, size = 14), 
        panel.border = element_rect(colour = "black", fill = NA, size = 2),
        panel.background = element_rect(colour = "white", fill = NA)) +
  theme_classic()->plot.5

gridExtra::grid.arrange(plot.2, plot.3, plot.4, plot.5, ncol=2)

#Model 1: Moderating role of IRI (full scale)

df.study2.crits$rewarded <- df.study2.crits$rewarded - mean(df.study2.crits$rewarded, na.rm = TRUE)
df.study2.crits$last.common <- df.study2.crits$common - mean(df.study2.crits$common, na.rm  = TRUE)
df.study2.crits$repeated <- df.study2.crits$stay
df.study2.crits$IRI_Total <- df.study2.crits$IRI_Total - mean(df.study2.crits$IRI_Total, na.rm =TRUE)
df.study2.crits$IRI_PD <- df.study2.crits$IRI_PD - mean(df.study2.crits$IRI_PD, na.rm = TRUE)
df.study2.crits$IRI_PT <- df.study2.crits$IRI_PT - mean(df.study2.crits$IRI_PT, na.rm =  TRUE)
df.study2.crits$IRI_EC <- df.study2.crits$IRI_EC - mean(df.study2.crits$IRI_EC, na.rm = TRUE)
df.study2.crits$IRI_FS <- df.study2.crits$IRI_FS - mean(df.study2.crits$IRI_FS, na.rm = TRUE)

model1 <- glmer(repeated ~ rewarded * last.common * IRI_Total + 
                  (1 + rewarded  * last.common * IRI_Total|subject) + (1 + rewarded * last.common|social_agent_id), 
                data = df.study2.crits,family = binomial) 

summary(model1)

model2 <- glmer(repeated ~ rewarded * last.common * IRI_PD * IRI_FS * IRI_EC *IRI_PT + 
                  (1 + rewarded * last.common * IRI_PD * IRI_FS * IRI_EC *IRI_PT|subject) + 
                  (1 + rewarded * last.common|social_agent_id),
                data = df.study2.crits,family = binomial) 


summary(model2)

model3 <- glmer(repeated ~ rewarded * last.common * IRI_Total * IRI_PD * IRI_FS * IRI_EC *IRI_PT + 
                  (1 + rewarded * last.common * IRI_Total * IRI_PD * IRI_FS * IRI_EC *IRI_PT|subject) + 
                  (1 + rewarded * last.common|social_agent_id),
                data = df.study2.crits,family = binomial) 


summary(model3)

sjPlot::tab_model(model1, file = 'outputs/study_iri_full_logreg_moderator.doc')
sjPlot::tab_model(model2, file = 'outputs/study_iri_subscales_logreg_moderator.doc')
sjPlot::tab_model(model3, file = 'outputs/study_iri_full_subscales_logreg_moderator.doc')

