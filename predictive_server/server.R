#!/usr/bin/env Rscript

library(plumber)
#setwd("/home/ec2-user")
setwd("/Users/longnguyen/Documents/295/neuro-analytics/predictive_server")

r <- plumb("endpoint.R")
r$run(port=8000)
