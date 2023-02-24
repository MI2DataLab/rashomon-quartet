# Rashomon's quartet

## Read data

```
train <- read.table("rq_train.csv", sep=";", header=TRUE)
test  <- read.table("rq_test.csv", sep=";", header=TRUE)
```

## Train models

```
set.seed(1568) 

library(partykit)
model_dt <- ctree(y~., data = train, control = ctree_control(maxdepth = 3, minsplit = 250))
exp_dt <- DALEX::explain(model_dt, data = test[,-1], y = test[,1], 
                         verbose = FALSE, label="decision tree")
mp_dt <- model_performance(exp_dt)
imp_dt <- model_parts(exp_dt, N=NULL, B=1, type = "difference")

model_lm <- lm(y~., data = train)
exp_lm <- DALEX::explain(model_lm, data = test[,-1], y = test[,1], 
                         verbose = FALSE, label="linear regression")
mp_lm <- model_performance(exp_lm)
imp_lm <- model_parts(exp_lm, N=NULL, B=1, type = "difference")

library(randomForest)
model_rf <- randomForest(y~., data = train, ntree = 100)
exp_rf <- DALEX::explain(model_rf, data = test[,-1], y = test[,1], 
                         verbose = FALSE, label="random forest")
mp_rf <- model_performance(exp_rf)
imp_rf <- model_parts(exp_rf, N=NULL, B=1, type = "difference")

library(neuralnet)
model_nn <- neuralnet(y~., data = train, hidden=c(8, 4), threshold=0.05)
exp_nn <- DALEX::explain(model_nn, data = test[,-1], y = test[,1], 
                        verbose = FALSE, label="neural network")
mp_nn <- model_performance(exp_nn)
imp_nn <- model_parts(exp_nn, N=NULL, B=1, type = "difference")

# save binary versions just in case
save(exp_nn, exp_df, exp_rm, exp_lm, file="models.RData")
```

## Let's see performance

```
mp_all <- list(lm = mp_lm, dt = mp_dt, nn = mp_nn, rf = mp_rf)

R2   <- sapply(mp_all, function(x) x$measures$r2)
rmse <- sapply(mp_all, function(x) x$measures$rmse)
```

## Let's see raw models

```
plot(model_dt)
summary(model_lm)
model_rf
plot(model_nn)
```

## Variable importance

```
plot(imp_dt, imp_nn, imp_rf, imp_lm)
```

## Plot models

```
pd_dt <- model_profile(exp_dt, N=NULL)
pd_rf <- model_profile(exp_rf, N=NULL)
pd_lm <- model_profile(exp_lm, N=NULL)
pd_nn <- model_profile(exp_nn, N=NULL)

plot(pd_dt, pd_nn, pd_rf, pd_lm)
```

## Session info

```
> devtools::session_info()
─ Session info ──────────────────────────────────────────────────────────────────
 setting  value
 version  R version 4.2.2 (2022-10-31)
 os       macOS Monterey 12.5.1
 system   aarch64, darwin20
 ui       RStudio
 language (EN)
 collate  en_US.UTF-8
 ctype    en_US.UTF-8
 tz       Europe/Warsaw
 date     2023-02-24
 rstudio  2022.12.0+353 Elsbeth Geranium (desktop)
 pandoc   2.19.2 @ /Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/ (via rmarkdown)

─ Packages ──────────────────────────────────────────────────────────────────────
 package      * version    date (UTC) lib source
 backports      1.4.1      2021-12-13 [1] CRAN (R 4.2.0)
 base64enc      0.1-3      2015-07-28 [1] CRAN (R 4.2.0)
 bookdown       0.32       2023-01-17 [1] CRAN (R 4.2.0)
 cachem         1.0.6      2021-08-19 [1] CRAN (R 4.2.0)
 callr          3.7.3      2022-11-02 [1] CRAN (R 4.2.0)
 caret        * 6.0-93     2022-08-09 [1] CRAN (R 4.2.0)
 checkmate      2.1.0      2022-04-21 [1] CRAN (R 4.2.0)
 class          7.3-20     2022-01-16 [1] CRAN (R 4.2.2)
 cli            3.6.0      2023-01-09 [1] CRAN (R 4.2.0)
 cluster        2.1.4      2022-08-22 [1] CRAN (R 4.2.2)
 codetools      0.2-18     2020-11-04 [1] CRAN (R 4.2.2)
 colorspace     2.1-0      2023-01-23 [1] CRAN (R 4.2.0)
 crayon         1.5.2      2022-09-29 [1] CRAN (R 4.2.0)
 ctv            0.9-4      2022-11-06 [1] CRAN (R 4.2.0)
 DALEX        * 2.4.3      2023-01-15 [1] Github (ModelOriented/DALEX@478a19d)
 data.table     1.14.6     2022-11-16 [1] CRAN (R 4.2.0)
 deldir         1.0-6      2021-10-23 [1] CRAN (R 4.2.0)
 devtools       2.4.5      2022-10-11 [1] CRAN (R 4.2.0)
 digest         0.6.30     2022-10-18 [1] CRAN (R 4.2.0)
 dplyr          1.1.0      2023-01-29 [1] CRAN (R 4.2.0)
 ellipsis       0.3.2      2021-04-29 [1] CRAN (R 4.2.0)
 evaluate       0.18       2022-11-07 [1] CRAN (R 4.2.0)
 fansi          1.0.4      2023-01-22 [1] CRAN (R 4.2.0)
 farver         2.1.1      2022-07-06 [1] CRAN (R 4.2.0)
 fastmap        1.1.0      2021-01-25 [1] CRAN (R 4.2.0)
 foreach        1.5.2      2022-02-02 [1] CRAN (R 4.2.0)
 foreign        0.8-83     2022-09-28 [1] CRAN (R 4.2.2)
 Formula      * 1.2-4      2020-10-16 [1] CRAN (R 4.2.0)
 fs             1.6.1      2023-02-06 [1] CRAN (R 4.2.0)
 future         1.29.0     2022-11-06 [1] CRAN (R 4.2.0)
 future.apply   1.10.0     2022-11-05 [1] CRAN (R 4.2.0)
 generics       0.1.3      2022-07-05 [1] CRAN (R 4.2.0)
 ggplot2      * 3.4.0      2022-11-04 [1] CRAN (R 4.2.0)
 glmnet       * 4.1-6      2022-11-27 [1] CRAN (R 4.2.0)
 globals        0.16.2     2022-11-21 [1] CRAN (R 4.2.0)
 glue           1.6.2      2022-02-24 [1] CRAN (R 4.2.0)
 gower          1.0.1      2022-12-22 [1] CRAN (R 4.2.0)
 gridExtra      2.3        2017-09-09 [1] CRAN (R 4.2.0)
 gtable         0.3.1      2022-09-01 [1] CRAN (R 4.2.0)
 hardhat        1.2.0      2022-06-30 [1] CRAN (R 4.2.0)
 Hmisc        * 4.7-2      2022-11-18 [1] CRAN (R 4.2.0)
 htmlTable      2.4.1      2022-07-07 [1] CRAN (R 4.2.0)
 htmltools      0.5.3      2022-07-18 [1] CRAN (R 4.2.0)
 htmlwidgets    1.5.4      2021-09-08 [1] CRAN (R 4.2.0)
 httpuv         1.6.6      2022-09-08 [1] CRAN (R 4.2.0)
 ingredients    2.3.1      2023-01-15 [1] Github (ModelOriented/ingredients@a63c06c)
 interp         1.1-3      2022-07-13 [1] CRAN (R 4.2.0)
 inum           1.0-4      2021-04-12 [1] CRAN (R 4.2.0)
 ipred          0.9-13     2022-06-02 [1] CRAN (R 4.2.0)
 iterators      1.0.14     2022-02-05 [1] CRAN (R 4.2.0)
 jpeg           0.1-10     2022-11-29 [1] CRAN (R 4.2.0)
 knitr          1.41       2022-11-18 [1] CRAN (R 4.2.0)
 labeling       0.4.2      2020-10-20 [1] CRAN (R 4.2.0)
 later          1.3.0      2021-08-18 [1] CRAN (R 4.2.0)
 lattice      * 0.20-45    2021-09-22 [1] CRAN (R 4.2.2)
 latticeExtra   0.6-30     2022-07-04 [1] CRAN (R 4.2.0)
 lava           1.7.1      2023-01-06 [1] CRAN (R 4.2.0)
 libcoin      * 1.0-9      2021-09-27 [1] CRAN (R 4.2.0)
 lifecycle      1.0.3      2022-10-07 [1] CRAN (R 4.2.0)
 listenv        0.8.0      2019-12-05 [1] CRAN (R 4.2.0)
 lubridate      1.9.0      2022-11-06 [1] CRAN (R 4.2.0)
 magrittr       2.0.3      2022-03-30 [1] CRAN (R 4.2.0)
 MASS         * 7.3-58.1   2022-08-03 [1] CRAN (R 4.2.2)
 Matrix       * 1.5-3      2022-11-11 [1] CRAN (R 4.2.0)
 MatrixModels   0.5-1      2022-09-11 [1] CRAN (R 4.2.0)
 memoise        2.0.1      2021-11-26 [1] CRAN (R 4.2.0)
 mime           0.12       2021-09-28 [1] CRAN (R 4.2.0)
 miniUI         0.1.1.1    2018-05-18 [1] CRAN (R 4.2.0)
 ModelMetrics   1.2.2.2    2020-03-17 [1] CRAN (R 4.2.0)
 multcomp       1.4-20     2022-08-07 [1] CRAN (R 4.2.0)
 munsell        0.5.0      2018-06-12 [1] CRAN (R 4.2.0)
 mvtnorm      * 1.1-3      2021-10-08 [1] CRAN (R 4.2.0)
 neuralnet    * 1.44.2     2019-02-07 [1] CRAN (R 4.2.0)
 nlme           3.1-161    2022-12-15 [1] CRAN (R 4.2.0)
 nnet           7.3-18     2022-09-28 [1] CRAN (R 4.2.2)
 parallelly     1.32.1     2022-07-21 [1] CRAN (R 4.2.0)
 partykit     * 1.2-16     2022-06-20 [1] CRAN (R 4.2.0)
 patchwork    * 1.1.2      2022-08-19 [1] CRAN (R 4.2.0)
 pillar         1.8.1      2022-08-19 [1] CRAN (R 4.2.0)
 pkgbuild       1.4.0      2022-11-27 [1] CRAN (R 4.2.0)
 pkgconfig      2.0.3      2019-09-22 [1] CRAN (R 4.2.0)
 pkgload        1.3.2      2022-11-16 [1] CRAN (R 4.2.0)
 plyr           1.8.8      2022-11-11 [1] CRAN (R 4.2.0)
 png            0.1-8      2022-11-29 [1] CRAN (R 4.2.0)
 polspline      1.1.22     2022-11-23 [1] CRAN (R 4.2.0)
 prettyunits    1.1.1      2020-01-24 [1] CRAN (R 4.2.0)
 pROC           1.18.0     2021-09-03 [1] CRAN (R 4.2.0)
 processx       3.8.0      2022-10-26 [1] CRAN (R 4.2.0)
 prodlim        2019.11.13 2019-11-17 [1] CRAN (R 4.2.0)
 profvis        0.3.7      2020-11-02 [1] CRAN (R 4.2.0)
 promises       1.2.0.1    2021-02-11 [1] CRAN (R 4.2.0)
 ps             1.7.2      2022-10-26 [1] CRAN (R 4.2.0)
 purrr          1.0.1      2023-01-10 [1] CRAN (R 4.2.0)
 quantreg       5.94       2022-07-20 [1] CRAN (R 4.2.0)
 R6             2.5.1      2021-08-19 [1] CRAN (R 4.2.0)
 randomForest * 4.7-1.1    2022-05-23 [1] CRAN (R 4.2.0)
 RColorBrewer   1.1-3      2022-04-03 [1] CRAN (R 4.2.0)
 Rcpp           1.0.10     2023-01-22 [1] CRAN (R 4.2.0)
 recipes        1.0.4      2023-01-11 [1] CRAN (R 4.2.0)
 remotes        2.4.2      2021-11-30 [1] CRAN (R 4.2.0)
 reshape2       1.4.4      2020-04-09 [1] CRAN (R 4.2.0)
 rlang          1.0.6      2022-09-24 [1] CRAN (R 4.2.0)
 rmarkdown      2.18       2022-11-09 [1] CRAN (R 4.2.0)
 rms          * 6.3-0      2022-04-22 [1] CRAN (R 4.2.0)
 rpart        * 4.1.19     2022-10-21 [1] CRAN (R 4.2.0)
 rstudioapi     0.14       2022-08-22 [1] CRAN (R 4.2.0)
 sandwich       3.0-2      2022-06-15 [1] CRAN (R 4.2.0)
 scales         1.2.1      2022-08-20 [1] CRAN (R 4.2.0)
 sessioninfo    1.2.2      2021-12-06 [1] CRAN (R 4.2.0)
 shape          1.4.6      2021-05-19 [1] CRAN (R 4.2.0)
 shiny          1.7.3      2022-10-25 [1] CRAN (R 4.2.0)
 SparseM      * 1.81       2021-02-18 [1] CRAN (R 4.2.0)
 stringi        1.7.12     2023-01-11 [1] CRAN (R 4.2.0)
 stringr        1.5.0      2022-12-02 [1] CRAN (R 4.2.0)
 survival     * 3.4-0      2022-08-09 [1] CRAN (R 4.2.2)
 TH.data        1.1-1      2022-04-26 [1] CRAN (R 4.2.0)
 tibble         3.1.8      2022-07-22 [1] CRAN (R 4.2.0)
 tidyselect     1.2.0      2022-10-10 [1] CRAN (R 4.2.0)
 timechange     0.2.0      2023-01-11 [1] CRAN (R 4.2.0)
 timeDate       4022.108   2023-01-07 [1] CRAN (R 4.2.0)
 urlchecker     1.0.1      2021-11-30 [1] CRAN (R 4.2.0)
 usethis        2.1.6      2022-05-25 [1] CRAN (R 4.2.0)
 utf8           1.2.3      2023-01-31 [1] CRAN (R 4.2.0)
 vctrs          0.5.2      2023-01-23 [1] CRAN (R 4.2.0)
 withr          2.5.0      2022-03-03 [1] CRAN (R 4.2.0)
 xfun           0.37       2023-01-31 [1] CRAN (R 4.2.0)
 xtable         1.8-4      2019-04-21 [1] CRAN (R 4.2.0)
 yaml           2.3.7      2023-01-23 [1] CRAN (R 4.2.0)
 zoo            1.8-11     2022-09-17 [1] CRAN (R 4.2.0)
```
 
