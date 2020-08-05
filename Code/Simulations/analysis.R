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

sigma.mf <- read_csv('sims1_sigma_MF.csv')%>%
  arrange(sub_id)

#get criticial trials
sigma.mf.crits <- sigma.mf%>%
  dplyr::mutate(
    social_turn = turn==2 
  ) %>%
  filter(trial_n != min(trial_n, na.rm=TRUE)) %>%#remove first trial which was agent trial
  dplyr::mutate(
    last.common.fac = factor(lag(s2)==(lag(c1)+1), c(T,F), c('Common','Rare')),
    last.common = lag(s2)==(lag(c1)+1),
    stay = c1 == lag(c1),
    stay.fac = factor(c1==lag(c1), c(T,F), c('Same ction1','Different action1')),
    rewarded = lag(re),
    rewarded.fac = factor(lag(re)>0, c(T,F), c("+ive reward", "-ive reward"))
  ) %>%
  filter(social_turn==FALSE)  #remove social turns


sigma.mf.bysubj <- sigma.mf.crits %>%
  na.omit()%>%
  dplyr::group_by(rewarded.fac, last.common.fac, sub_id) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE)
  )


sigma.mf.agg <- sigma.mf.bysubj %>%
  dplyr::group_by(last.common.fac, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )


#plot
ggplot(sigma.mf.agg, aes(x=rewarded.fac, y = prob.stay.mean, fill = last.common.fac)) +
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
  scale_fill_manual(values = c("Common" = "#69b3a2", "Rare" = "#404080")) +
  coord_cartesian(ylim=c(.0,.7)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = 'Reinforcement',
       title = "sigma_mf = 1; sigma_mb = 0") 


#BUILD A MODEL

#center data
sigma.mf.crits$rewarded <- sigma.mf.crits$rewarded - mean(sigma.mf.crits$rewarded, na.rm = TRUE)
sigma.mf.crits$last.common <- sigma.mf.crits$last.common - mean(sigma.mf.crits$last.common, na.rm =TRUE)

model.sigmaMF <- glmer(stay ~ rewarded * last.common + (1+rewarded * last.common|sub_id) + (1+rewarded * last.common|social_agent_id), 
                       family = binomial, data = sigma.mf.crits)


#ANALYSIS 2: SOCIAL MB

sigma.mb <- read_csv('sims1_sigma_MB.csv')%>%
  arrange(sub_id)


sigma.mb.crits <- sigma.mb%>%
  dplyr::mutate(
    social_turn = turn==2 
  ) %>%
  filter(trial_n != min(trial_n, na.rm=TRUE)) %>%#remove first trial which was agent trial
  dplyr::mutate(
    last.common.fac = factor(lag(s2)==(lag(c1)+1), c(T,F), c('Common','Rare')),
    last.common = lag(s2)==(lag(c1)+1),
    stay = c1 == lag(c1),
    stay.fac = factor(c1==lag(c1), c(T,F), c('Same ction1','Different action1')),
    rewarded = lag(re),
    rewarded.fac = factor(lag(re)>0, c(T,F), c("+ive reward", "-ive reward")),
  ) %>%
  filter(social_turn==FALSE)  #remove social turns


sigma.mb.bysubj <- sigma.mb.crits %>%
  na.omit()%>%
  dplyr::group_by(rewarded.fac, last.common.fac, sub_id) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE)
  )


sigma.mb.agg <- sigma.mb.bysubj %>%
  dplyr::group_by(last.common.fac, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )


#plot
ggplot(sigma.mb.agg, aes(x=rewarded.fac, y = prob.stay.mean, fill = last.common.fac)) +
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
  scale_fill_manual(values = c("Common" = "#69b3a2", "Rare" = "#404080")) +
  coord_cartesian(ylim=c(0,.6)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = 'Reinforcement',
       title = "sigma_mf = 0; sigma_mb = 1") 

#BUILD A MODEL

#center data
sigma.mb.crits$rewarded <- sigma.mb.crits$rewarded - mean(sigma.mb.crits$rewarded, na.rm = TRUE)
sigma.mb.crits$last.common <- sigma.mb.crits$last.common - mean(sigma.mb.crits$last.common, na.rm =TRUE)

model.sigmaMB <- glmer(stay ~ rewarded * last.common + (1+rewarded * last.common|sub_id) + (1+rewarded * last.common|social_agent_id), 
                       family = binomial, data = sigma.mb.crits)

#ANALYSIS 3: SOCIAL MF - MB

sigma.mfmb <- read_csv('sims1_sigma_MFMB.csv')%>%
  arrange(sub_id)


sigma.mfmb.crits <- sigma.mfmb%>%
  dplyr::mutate(
    social_turn = turn==2 
  ) %>%
  filter(trial_n != min(trial_n, na.rm=TRUE)) %>%#remove first trial which was agent trial
  dplyr::mutate(
    last.common.fac = factor(lag(s2)==(lag(c1)+1), c(T,F), c('Common','Rare')),
    last.common = lag(s2)==(lag(c1)+1),
    stay = c1 == lag(c1),
    stay.fac = factor(c1==lag(c1), c(T,F), c('Same action1','Different action1')),
    rewarded = lag(re),
    rewarded.fac = factor(lag(re)>0, c(T,F), c("+ive reward", "-ive reward"))
  ) %>%
  filter(social_turn==FALSE)  #remove social turns


sigma.mfmb.bysubj <- sigma.mfmb.crits %>%
  na.omit()%>%
  dplyr::group_by(rewarded.fac, last.common.fac, sub_id) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE)
  )


sigma.mfmb.agg <- sigma.mfmb.bysubj %>%
  dplyr::group_by(last.common.fac, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )


#plot
ggplot(sigma.mfmb.agg, aes(x=rewarded.fac, y = prob.stay.mean, fill = last.common.fac)) +
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
  scale_fill_manual(values =c("Common" = "#69b3a2", "Rare" = "#404080")) +
  coord_cartesian(ylim=c(0,.8)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = 'Reinforcement',
       title = "sigma_mf = 1; sigma_mb = 1") 

#BUILD A MODEL

#center data
sigma.mfmb.crits$rewarded <- sigma.mfmb.crits$rewarded- mean(sigma.mfmb.crits$rewarded, na.rm = TRUE)
sigma.mfmb.crits$last.common <- sigma.mfmb.crits$last.common- mean(sigma.mfmb.crits$last.common, na.rm =TRUE)

model.sigmaMFMB <- glmer(stay ~ rewarded * last.common + (1+rewarded * last.common|sub_id) + (1+rewarded * last.common|social_agent_id), 
                       family = binomial, data = sigma.mfmb.crits)

#ANALYSIS 4: nNO SOCIAL MF-MB

no_sigma.MFMB <- read_csv('sims1__no_sigma_MFMB.csv')%>%
  arrange(sub_id)


no_sigma.MFMB.crits <- no_sigma.MFMB%>%
  dplyr::mutate(
    social_turn = turn==2 
  ) %>%
  filter(trial_n != min(trial_n, na.rm=TRUE)) %>%#remove first trial which was agent trial
  dplyr::mutate(
    last.common.fac = factor(lag(s2)==(lag(c1)+1), c(T,F), c('Common','Rare')),
    last.common = lag(s2)==(lag(c1)+1),
    stay = c1 == lag(c1),
    stay.fac = factor(c1==lag(c1), c(T,F), c('Same action1','Different action1')),
    rewarded = lag(re),
    rewarded.fac = factor(lag(re)>0, c(T,F), c("+ive reward", "-ive reward"))
  ) %>%
  filter(social_turn==FALSE)  #remove social turns


no_sigma.MFMB.bysubj <- no_sigma.MFMB.crits %>%
  na.omit()%>%
  dplyr::group_by(rewarded.fac, last.common.fac, sub_id) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE)
  )


no_sigma.MFMB.agg <-no_sigma.MFMB.bysubj %>%
  dplyr::group_by(last.common.fac, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )


#plot
ggplot(no_sigma.MFMB.agg, aes(x=rewarded.fac, y = prob.stay.mean, fill = last.common.fac)) +
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
  scale_fill_manual(values =c("Common" = "#69b3a2", "Rare" = "#404080")) +
  coord_cartesian(ylim=c(.0,.6)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = 'Reinforcement',
       title = "sigma mf = 0 and sigma_mb = 0") 

#BUILD A MODEL

#center data
no_sigma.MFMB.crits$rewarded <- no_sigma.MFMB.crits$rewarded- mean(no_sigma.MFMB.crits$rewarded, na.rm = TRUE)
no_sigma.MFMB.crits$last.common <- no_sigma.MFMB.crits$last.common- mean(no_sigma.MFMB.crits$last.common, na.rm =TRUE)

model.no_sigmaMFMB <- glmer(stay ~ rewarded * last.common + (1+rewarded * last.common|sub_id) + (1+rewarded * last.common|social_agent_id), 
                         family = binomial, data = no_sigma.MFMB.crits)



#ANALYSIS 5: RANDOM SIGMAS

rand_sigma.MFMB <- read_csv('sims1_random_sigma_MFMB.csv')%>%
  arrange(sub_id)


rand_sigma.MFMB.crits <- rand_sigma.MFMB%>%
  dplyr::mutate(
    social_turn = turn==2 
  ) %>%
  filter(trial_n != min(trial_n, na.rm=TRUE)) %>%#remove first trial which was agent trial
  dplyr::mutate(
    last.common.fac = factor(lag(s2)==(lag(c1)+1), c(T,F), c('Common','Rare')),
    last.common = lag(s2)==(lag(c1)+1),
    stay = c1 == lag(c1),
    stay.fac = factor(c1==lag(c1), c(T,F), c('Same action1','Different action1')),
    rewarded = lag(re),
    rewarded.fac = factor(lag(re)>0, c(T,F), c("+ive reward", "-ive reward"))
  ) %>%
  filter(social_turn==FALSE)  #remove social turns


rand_sigma.MFMB.bysubj <- rand_sigma.MFMB.crits %>%
  na.omit()%>%
  dplyr::group_by(rewarded.fac, last.common.fac, sub_id) %>%
  dplyr::summarize(
    prob.stay = mean(stay, na.rm = TRUE)
  )


rand_sigma.MFMB.agg <- rand_sigma.MFMB.bysubj %>%
  dplyr::group_by(last.common.fac, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )


#plot
ggplot(rand_sigma.MFMB.agg, aes(x=rewarded.fac, y = prob.stay.mean, fill = last.common.fac)) +
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
  scale_fill_manual(values =c("Common" = "#69b3a2", "Rare" = "#404080")) +
  coord_cartesian(ylim=c(.0,.6)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = 'Reinforcement',
       title = "sigma mf = rand() and sigma_mb = rand()") 

#BUILD A MODEL

#center data
rand_sigma.MFMB.crits$rewarded <- rand_sigma.MFMB.crits$rewarded- mean(rand_sigma.MFMB.crits$rewarded, na.rm = TRUE)
rand_sigma.MFMB.crits$last.common <- rand_sigma.MFMB.crits$last.common- mean(rand_sigma.MFMB.crits$last.common, na.rm =TRUE)

model.rand_sigmaMFMB <- glmer(stay ~ rewarded * last.common + (1+rewarded * last.common|sub_id) + (1+rewarded * last.common|social_agent_id), 
                            family = binomial, data = rand_sigma.MFMB.crits)


