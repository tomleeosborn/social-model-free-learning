
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


#with sigma mf = 1; sigma mb = 0

sigma.mf <- read_csv('sigma_mf2.csv')%>%
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
  filter(social_turn==FALSE)  

#glm model
model.sigmaMF <- glmer(stay ~ rewarded * last.common + (1+rewarded * last.common|sub_id) + (1|social_agent_id), 
                       family = binomial, data = sigma.mf.crits)

summary(model.sigmaMF)


reward.effect <- fixed.effects(model.sigmaMF)[2]

fixef(model.sigmaMF)['rewarded'] <- 0.01

powersim1 <- powerSim(model.sigmaMF, fixed('rewarded','z'), nsim=1)

powercurve1 <- powerCurve(fit = model.sigmaMF, along = 'rewarded', test = fixed('rewarded'), nsim=10)

plot(powercurve1)

     