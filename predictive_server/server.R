#!/usr/bin/env Rscript

library(plumber)

source("/tmp/config.R")
setwd(workingDirectory)

r <- plumb("endpoint.R")
r$run(port=8000)
