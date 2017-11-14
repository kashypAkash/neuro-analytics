#!/usr/bin/env Rscript

library(plumber)

source("~/config.R")
setwd(predictiveDirectory)

r <- plumb("endpoint.R")
r$run(port=8000)
