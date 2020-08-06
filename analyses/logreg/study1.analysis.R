
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

df <- read_csv('../../data/cleaned/study1_full_data_cleaned.csv')

#relevel for graphing
df$last.common.fac <- factor(df$last.common, levels = c(1,0), 
                        labels = c('Common','Rare'))
df$last.common.fac <- relevel(df$last.common.fac, ref = "Common")

df$rewarded.fac <- factor(df$last.reward.sign,levels = c(F,T), 
                          labels = c("-ive reward", "+ive reward"))
df$rewarded.fac <- relevel(df$rewarded.fac, ref = "+ive reward")



df.bysubj <- df %>% 
  na.omit()%>%
  dplyr::group_by(rewarded.fac, last.common.fac, subject) %>%
  dplyr::summarize(
    prob.stay = mean(repeated, na.rm = TRUE)
  )

df.agg <- df.bysubj %>%
  dplyr::group_by(last.common.fac, rewarded.fac) %>%
  dplyr::summarize(
    prob.stay.mean = mean(prob.stay),
    prob.stay.se = sd(prob.stay)/sqrt(n())
  )

#plot
ggplot(df.agg, aes(x=rewarded.fac, y = prob.stay.mean,fill = last.common.fac)) +
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
  labs(fill ='Transition',
       y = 'Stay probability',
       x = '',
       title = 'Stay probability after social trials (Study 1)')



## MODEL

#center data
df$last.reward <-  df$Re- mean (df$Re, na.rm = TRUE)
df$last.common <-  df$last.common - mean(df$last.common, na.rm = TRUE)


df$last.common
##NOW BUILD A MIXED EFFECT MODEL 

model1 <- glmer(repeated ~ last.reward * last.common + 
                  (1 + last.reward * last.common|subject) + (1+last.reward*last.common|matched_player_id), 
                data = df,family = binomial)

summary(model1)

sjPlot::tab_model(model1, show.est = T, file = 'outputs/study1_logreg.doc')
