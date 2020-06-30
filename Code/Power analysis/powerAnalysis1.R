
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
if (!require(simr)) {install.packages("simr"); require(simr)}
#set working directory to the directory where script is residing 
groupedstats:::set_cwd()


#load data

df <- read_csv('study_1_human_crits.csv')

#relevel for graphing
df$common.fac <- factor(df$last.common, levels = c(0,1), 
                               labels = c('Rare','Common'))
df$common.fac <- relevel(df$common.fac, ref = "Common")

df$rewarded.fac <- factor(df$last.reward.sign,levels = c(F,T), 
                                 labels = c("Punished","Rewarded"))
df$rewarded.fac <- relevel(df$rewarded.fac, ref = "Rewarded")

df.bysubj <- df %>% 
  na.omit()%>%
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
  coord_cartesian(ylim=c(0,.7)) + 
  labs(fill = 'Transition',
       y = 'Stay probability',
       x = '',
       title = 'Person condition')


## MODEL

#center data
df$rewarded <-  df$rewarded - mean (df$rewarded, na.rm = TRUE)
df$common <-  df$common - mean(df$common, na.rm = TRUE)
df$cXr <-  df$rewarded *  df$common

df <- df %>%
  na.omit(df)


##NOW BUILD A MIXED EFFECT MODEL 

model1 <- glmer(repeated ~ rewarded + common + cXr +
                 (1 + rewarded + common + cXr|subject) + (1|matched_player_id), 
               data = df,family = binomial)

summary(model1)

#extend to 500 subjects
model2 <- extend(model1, along = "subject", n = 500)

df1 <- getData(model2)
table(df1$subject)
pc1 <- powerCurve(model2, along  = "subject", nsim=100, breaks = c(0,10,20,30,40,50,75,100,
                                                                   125,250,300,450,500))

df.sims <- read_csv('power.sim.results.csv')               

df.sims %>%
  ggplot(aes(x = subject, y=power)) +
  geom_line() + 
  geom_errorbar(
    aes(ymin = lb, ymax = up),
    width = .2,
    position = position_dodge(width = .9)
  ) + scale_x_continuous( breaks = c(0,10,20,30,40,50,75,100,
                                     125,250,300,450,500))
  

view(df.sims)
