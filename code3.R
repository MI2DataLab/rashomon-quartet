library(MASS)
library(partykit)
library(randomForest)
library(DALEX)
library(neuralnet)
library(ggplot2)

generate_data <- function(n=1000, p=3, rho=0.9, noise=1/3, 
                          scale=1.275, share=0.9, seed=2970, eps=0.1) {
  Mu = rep(0, p)
  # Sigma = matrix(rep(rho, p**2), p, p)
  # diag(Sigma) <- 1
  Sigma = matrix(c(1, -rho, eps, -rho, 1, eps, eps, eps, 1/3), p, p)
  
  set.seed(seed) 
  X_train <- mvrnorm(n, Mu, Sigma)
  X_test <-  mvrnorm(n, Mu, Sigma)
  # print(hist((share*X_train[,1] - (1-share)*X_train[,2]) / scale))
  generate_y <- function(X) sin((share*X[,1] - (1-share)*X[,2]) / scale) + rnorm(n, 0, noise)

  df_train <- data.frame(y = generate_y(X_train), 
                         x1 = X_train[,1], 
                         x2 = X_train[,2], 
                         x3 = X_train[,3])
  df_test <- data.frame(y = generate_y(X_test), 
                        x1 = X_test[,1], 
                        x2 = X_test[,2], 
                        x3 = X_test[,3])
  list(train=df_train, test=df_test)
}

train_models <- function(data, seed=2970, benchmark=FALSE) {
  df_train <- data$train
  df_test <- data$test
  
  set.seed(seed) 
  model_dt <- ctree(y~., data = df_train, control = ctree_control(maxdepth = 3, minsplit = 250))
  exp_dt <- DALEX::explain(model_dt, data = df_test[,-1], y = df_test[,1], 
                             verbose = FALSE, label="decision tree")
  mp_dt <- model_performance(exp_dt)
  model_lm <- lm(y~., data = df_train)
  exp_lm <- DALEX::explain(model_lm, data = df_test[,-1], y = df_test[,1], 
                           verbose = FALSE, label="linear regression")
  mp_lm <- model_performance(exp_lm)
  model_rf <- randomForest(y~., data = df_train, ntree = 100)
  exp_rf <- DALEX::explain(model_rf, data = df_test[,-1], y = df_test[,1], 
                           verbose = FALSE, label="random forest")
  mp_rf <- model_performance(exp_rf)
  
  model_nn <- neuralnet(y~., data = df_train, hidden=c(8, 4), threshold=0.05)
  exp_nn <- DALEX::explain(model_nn, data = data$test[,-1], 
                           y = data$test[,1], verbose = FALSE, label="neural network")
  mp_nn <- model_performance(exp_nn)
  
  if (benchmark) {
    return(
      abs(round(mp_dt$measures$r2, 4) - round(mp_lm$measures$r2, 4)) +
       abs(round(mp_dt$measures$r2, 4) - round(mp_rf$measures$r2, 4)) +
        abs(round(mp_rf$measures$r2, 4) - round(mp_lm$measures$r2, 4)) +
      abs(round(mp_nn$measures$r2, 4) - round(mp_lm$measures$r2, 4)) +
        abs(round(mp_nn$measures$r2, 4) - round(mp_rf$measures$r2, 4)) +
          abs(round(mp_nn$measures$r2, 4) - round(mp_dt$measures$r2, 4))
    )
  } else {
    cat(' dt: ', mp_dt$measures$r2, '\n',
        'lm: ', mp_lm$measures$r2, '\n',
        'rf: ', mp_rf$measures$r2, '\n',
        'nn: ', mp_nn$measures$r2, '\n')
    
    list(dt=exp_dt, lm=exp_lm, rf=exp_rf, nn=exp_nn)  
  }
}

explain_models_pd <- function(explainers) {
  profiles <- list()
  for (i in 1:length(explainers)) {
    profiles[[i]] <- model_profile(explainers[[i]], N=NULL)
  }
  plot(profiles) + 
    scale_color_manual(values=DALEX::colors_discrete_drwhy(n=4)[c(2, 1, 3, 4)]) +
    labs(title="Partial dependence", subtitle=NULL, color=NULL) +
    DALEX::theme_ema() + 
    theme(legend.position = "top")
}

explain_models_ale <- function(explainers) {
  profiles <- list()
  for (i in 1:length(explainers)) {
    profiles[[i]] <- model_profile(explainers[[i]], N=NULL, type="accumulated", span=1e-2)
  }
  plot(profiles) + 
    scale_color_manual(values=DALEX::colors_discrete_drwhy(n=4)[c(2, 1, 3, 4)]) +
    labs(title="Accumulated local effects", subtitle=NULL, color=NULL) +
    DALEX::theme_ema() + 
    theme(legend.position = "top")
}

explain_models_fi <- function(explainers) {
  explanations <- list()
  for (i in 1:length(explainers)) {
    explanations[[i]] <- model_parts(explainers[[i]], N=NULL)
  }
  plot(explanations) + 
    scale_color_manual(NULL, 
                       values=DALEX::colors_discrete_drwhy(n=4)[c(2, 1, 3, 4)]) +
    labs(title="Feature importance", subtitle=NULL) +
    DALEX::theme_ema()
}

# example
data <- generate_data()
explainers <- train_models(data)
explain_models_pd(explainers)
explain_models_fi(explainers)

# benchmark for smallest performance difference
results <- list()
for (i in 1:250) {
  print(i)
  data <- generate_data(seed=i)
  results[[i]] <- train_models(data, seed=i, benchmark=TRUE)
}

# obtain final result 
i_best <- 11 # which.min(results) # 11
data <- generate_data(seed=i_best)
explainers <- train_models(data, seed=i_best)
explain_models_pd(explainers)
ggsave("figures/code3_pd.png", width=7, height=3.5)

explain_models_ale(explainers)
ggsave("figures/code3_ale.png", width=7, height=3.5)

explain_models_fi(explainers)
ggsave("figures/code3_fi.png", width=7, height=7)
