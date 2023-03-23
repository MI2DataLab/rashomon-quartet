# Performance is not enough: the story of Rashomon's quartet
# P. Biecek, H. Baniecki, M. Krzyziński, D. Cook. *Performance is not enough: the story of Rashomon’s quartet*. [arXiv:2302.13356v2](https://arxiv.org/abs/2302.13356v2)

## Read data
train <- read.table("rq_train.csv", sep=";", header=TRUE)
test  <- read.table("rq_test.csv", sep=";", header=TRUE)

## Train models
set.seed(1568) 
library(DALEX)

library(partykit)
model_dt <- ctree(y~., data = train, control = ctree_control(maxdepth = 3, minsplit = 250))
exp_dt <- DALEX::explain(model_dt, data = test[,-1], y = test[,1], 
                         verbose = FALSE, label="decision tree")
mp_dt <- model_performance(exp_dt)

model_lm <- lm(y~., data = train)
exp_lm <- DALEX::explain(model_lm, data = test[,-1], y = test[,1], 
                         verbose = FALSE, label="linear regression")
mp_lm <- model_performance(exp_lm)

library(randomForest)
model_rf <- randomForest(y~., data = train, ntree = 100)
exp_rf <- DALEX::explain(model_rf, data = test[,-1], y = test[,1], 
                         verbose = FALSE, label="random forest")
mp_rf <- model_performance(exp_rf)

library(neuralnet)
model_nn <- neuralnet(y~., data = train, hidden=c(8, 4), threshold=0.05)
exp_nn <- DALEX::explain(model_nn, data = test[,-1], y = test[,1], 
                        verbose = FALSE, label="neural network")
mp_nn <- model_performance(exp_nn)

# save binary versions just in case
save(exp_nn, exp_dt, exp_rf, exp_lm, file="models.RData")

## Let's see performance
mp_all <- list(lm = mp_lm, dt = mp_dt, nn = mp_nn, rf = mp_rf)

R2   <- sapply(mp_all, function(x) x$measures$r2)
round(R2, 4)
#     lm     dt     nn     rf 
# 0.7290 0.7287 0.7290 0.7287 

rmse <- sapply(mp_all, function(x) x$measures$rmse)
round(rmse, 4)
#     lm     dt     nn     rf 
# 0.3535 0.3537 0.3535 0.3537

## Let's see raw models
plot(model_dt)
summary(model_lm)
model_rf
plot(model_nn)

## Variable importance
imp_dt <- model_parts(exp_dt, N=NULL, B=1, type = "difference")
imp_lm <- model_parts(exp_lm, N=NULL, B=1, type = "difference")
imp_rf <- model_parts(exp_rf, N=NULL, B=1, type = "difference")
imp_nn <- model_parts(exp_nn, N=NULL, B=1, type = "difference")

plot(imp_dt, imp_nn, imp_rf, imp_lm)

## Plot models
pd_dt <- model_profile(exp_dt, N=NULL)
pd_rf <- model_profile(exp_rf, N=NULL)
pd_lm <- model_profile(exp_lm, N=NULL)
pd_nn <- model_profile(exp_nn, N=NULL)

plot(pd_dt, pd_nn, pd_rf, pd_lm)

## Plot data distribution
library("GGally")
both <- rbind(data.frame(train, label="train"),
              data.frame(test, label="test"))
ggpairs(both, aes(color=label),
        lower = list(continuous = wrap("points", alpha=0.2, size=1), 
                     combo = wrap("facethist", bins=25)),
        diag = list(continuous = wrap("densityDiag", alpha=0.5, bw="SJ"), 
                    discrete = "barDiag"),
        upper = list(continuous = wrap("cor", stars=FALSE))) 

