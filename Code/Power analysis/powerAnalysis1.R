
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

model <- glmer(repeated ~ rewarded * common + 
                        (1 + rewarded * common|subject) + (1|matched_player_id), 
                      data = df,family = binomial)
summary(model)
model2 <- extend(model, within = "rewarded,common", n=5000)
model2.data <- getData(model2)

model_extended <-  glmer(repeated ~ rewarded * common + 
                           (1 + rewarded * common|subject) + (1|matched_player_id), 
                         data = model2.data,family = binomial)

summary(model_extended)
doTest(model, fcompare(~rewarded))

model_sim <- powerSim(model, nsim = 100, test = fcompare(~rewarded))

model_sim
model_pc1 <- powerCurve(model_extended, test =  fcompare(~rewarded),  within = "rewarded,common",
                        breaks=c(100, 500, 1000, 2000, 3000, 5000, 76000, 10000), seed = 123, nsim= 5)

plot(model_pc1)


fixef(model)['rewarded'] <- 0.5 #change effect size ot 9.5
model_sim2 <- powerSim(model, nsim = 100, test = fcompare(~rewarded))
model_extension2 <- extend(model, within = "rewarded,common", n=5000)
model_extension2_data <- getData(model_extension2)

model_extended2 <-  glmer(repeated ~ rewarded * common + 
                           (1 + rewarded * common|subject) + (1|matched_player_id), 
                         data = model_extension2_data, family = binomial)

model_pc2 <- powerCurve(model_extended2, test =  fcompare(~rewarded+common),  
                        within = "rewarded,common",
                        breaks=c(10, 100, 500, 1000, 2000, 3000, 5000, 76000, 10000), seed = 123, nsim= 100)

plot(model_pc2)


#power analysis for exploratory analysis of AIC values

library(pwr)

power.t.test(d=.2, power = .8, alternative = "one.sided", type = 'paired')



                      
