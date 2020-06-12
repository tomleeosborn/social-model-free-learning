#ANALYSIS OF SIMULATED DATA 
#in these analyses, the parameters used to generate data in MATLAB were fixed
# beta = .7; learning rate = .8; elig = .5; model-free model-based weight = .5


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

#helper functions
se <- function(x) {sd(x) / sqrt(length(x))};
dodge <- position_dodge(width=0.9)



#ANALYSIS 1: SIGMA MF (social model-free = 1; social model-based = 0)

sigma.mf <- read_csv('sigma_MF1.csv')%>%
  arrange(sub_id)


sigma.mf.crits <- sigma.mf%>%
  dplyr::mutate(
    social_turn = turn==2 
  ) %>%
  filter(trial_n != min(trial_n, na.rm=TRUE)) %>%#remove first trial which was agent trial
  dplyr::mutate(
    last.common = factor(lag(s2)==(lag(c1)+1), c(T,F), c('Common','Rare')),
    stay = c1 == lag(c1),
    stay.fac = factor(c1==lag(c1), c(T,F), c('Same ction1','Different action1')),
    rewarded = lag(re),
    rewarded.fac = factor(lag(re)>0, c(T,F), c("+ive reward", "-ive reward")),
    sub_id = as.numeric(sub_id)
  ) %>%
  filter(social_turn==FALSE)  #remove social turns


sigma.mf.bysubj <- sigma.mf.crits %>%
  na.omit()%>%
  dplyr::group_by(rewarded.fac, last.common, sub_id) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE)
  )


sigma.mf.agg <- sigma.mf.bysubj %>%
  dplyr::group_by(last.common, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )


#plot
ggplot(sigma.mf.agg, aes(x=rewarded.fac, y = prob.stay.mean, fill = last.common)) +
  geom_bar(
    stat = 'identity',
    position = position_dodge(width = .9)
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
  scale_fill_manual(values = c("Common" = "#C02739", "Rare" = "#29C7AC")) +
  coord_cartesian(ylim=c(.0,.7)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = 'Reinforcement',
       title = "sigma_mf = 1; sigma_mb = 0") 

#model 


model.sigmaMF <- glmer(stay ~ rewarded * last.common + (1+rewarded * last.common|sub_id) + (1|social_agent_id), 
                       family = binomial, data = sigma.mf.crits, contrasts = list(last.common = contr.sum))

summary(model.sigmaMF)
#ANALYSIS 2: SOCIAL MB

sigma.mb <- read_csv('sigma_MB1.csv')%>%
  arrange(sub_id)


sigma.mb.crits <- sigma.mb%>%
  dplyr::mutate(
    social_turn = turn==2 
  ) %>%
  filter(trial_n != min(trial_n, na.rm=TRUE)) %>%#remove first trial which was agent trial
  dplyr::mutate(
    last.common = factor(lag(s2)==(lag(c1)+1), c(T,F), c('Common','Rare')),
    stay = c1 == lag(c1),
    stay.fac = factor(c1==lag(c1), c(T,F), c('Same ction1','Different action1')),
    rewarded = lag(re),
    rewarded.fac = factor(lag(re)>0, c(T,F), c("+ive reward", "-ive reward")),
    sub_id = as.numeric(sub_id)
  ) %>%
  filter(social_turn==FALSE)  #remove social turns


sigma.mb.bysubj <- sigma.mb.crits %>%
  na.omit()%>%
  dplyr::group_by(rewarded.fac, last.common, sub_id) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE)
  )


sigma.mb.agg <- sigma.mb.bysubj %>%
  dplyr::group_by(last.common, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )


#plot
ggplot(sigma.mb.agg, aes(x=rewarded.fac, y = prob.stay.mean, fill = last.common)) +
  geom_bar(
    stat = 'identity',
    position = position_dodge(width = .9)
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
  scale_fill_manual(values = c("Common" = "#C02739", "Rare" = "#29C7AC")) +
  coord_cartesian(ylim=c(0,.6)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = 'Reinforcement',
       title = "sigma_mf = 0; sigma_mb = 1") 

#model 


model.sigmaMB <- glmer(stay ~ rewarded * last.common + (1+rewarded * last.common|sub_id) + (1|social_agent_id), 
                       family = binomial, data = sigma.mb.crits, contrasts = list(last.common = contr.sum))

summary(model.sigmaMB)

#ANALYSIS 3: SOCIAL MF - MB

sigma.mfmb <- read_csv('sigma_MFMBF1.csv')%>%
  arrange(sub_id)


sigma.mfmb.crits <- sigma.mfmb%>%
  dplyr::mutate(
    social_turn = turn==2 
  ) %>%
  filter(trial_n != min(trial_n, na.rm=TRUE)) %>%#remove first trial which was agent trial
  dplyr::mutate(
    last.common = factor(lag(s2)==(lag(c1)+1), c(T,F), c('Common','Rare')),
    stay = c1 == lag(c1),
    stay.fac = factor(c1==lag(c1), c(T,F), c('Same ction1','Different action1')),
    rewarded = lag(re),
    rewarded.fac = factor(lag(re)>0, c(T,F), c("+ive reward", "-ive reward")),
    sub_id = as.numeric(sub_id)
  ) %>%
  filter(social_turn==FALSE)  #remove social turns


sigma.mfmb.bysubj <- sigma.mfmb.crits %>%
  na.omit()%>%
  dplyr::group_by(rewarded.fac, last.common, sub_id) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE)
  )


sigma.mfmb.agg <- sigma.mfmb.bysubj %>%
  dplyr::group_by(last.common, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )


#plot
ggplot(sigma.mfmb.agg, aes(x=rewarded.fac, y = prob.stay.mean, fill = last.common)) +
  geom_bar(
    stat = 'identity',
    position = position_dodge(width = .9)
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
  scale_fill_manual(values = c("Common" = "#C02739", "Rare" = "#29C7AC")) +
  coord_cartesian(ylim=c(0,.8)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = 'Reinforcement',
       title = "sigma_mf = 1; sigma_mb = 1") 

#model 


model.sigmaMFMB <- glmer(stay ~ rewarded * last.common + (1+rewarded * last.common|sub_id) + (1|social_agent_id), 
                         family = binomial, data = sigma.mfmb.crits, contrasts = list(last.common = contr.sum))


summary(model.sigmaMFMB)

#ANALYSIS 4: nNO SOCIAL MF-MB

df.w <- read_csv('no_sigma.csv')%>%
  arrange(sub_id)


df.w.crits <- df.w%>%
  dplyr::mutate(
    social_turn = turn==2 
  ) %>%
  filter(trial_n != min(trial_n, na.rm=TRUE)) %>%#remove first trial which was agent trial
  dplyr::mutate(
    last.common = factor(lag(s2)==(lag(c1)+1), c(T,F), c('Common','Rare')),
    stay = c1 == lag(c1),
    stay.fac = factor(c1==lag(c1), c(T,F), c('Same ction1','Different action1')),
    rewarded = lag(re),
    rewarded.fac = factor(lag(re)>0, c(T,F), c("+ive reward", "-ive reward")),
    sub_id = as.numeric(sub_id)
  ) %>%
  filter(social_turn==FALSE)  #remove social turns


df.w.bysubj <- df.w.crits %>%
  na.omit()%>%
  dplyr::group_by(rewarded.fac, last.common, sub_id) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE)
  )


df.w.agg <- df.w.bysubj %>%
  dplyr::group_by(last.common, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )


#plot
ggplot(df.w.agg, aes(x=rewarded.fac, y = prob.stay.mean, fill = last.common)) +
  geom_bar(
    stat = 'identity',
    position = position_dodge(width = .9)
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
  scale_fill_manual(values = c("Common" = "#C02739", "Rare" = "#29C7AC")) +
  coord_cartesian(ylim=c(.0,.6)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = 'Reinforcement',
       title = "sigma mf = 0 and sigma_mb = 0") 

#model 


model.no.sigmaMFMB <- glmer(stay ~ rewarded * last.common + (1+rewarded * last.common|sub_id) + (1|social_agent_id), 
                            family = binomial, data = df.w.crits, contrasts = list(last.common = contr.sum))


summary(model.no.sigmaMFMB)

