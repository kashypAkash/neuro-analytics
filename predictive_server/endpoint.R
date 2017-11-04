library(RMySQL)
library(MASS)
library(e1071)

#setwd("/home/ec2-user")
setwd("/Users/longnguyen/Documents/295/neuro-analytics/predictive_server")

model_dir = "model"
load(file = file.path(model_dir, paste0("mod", ".rda")))
con = dbConnect(RMySQL::MySQL(),
                 user="mark", password="mark",
                 dbname="test", host="54.191.65.138")

#* @get /predict
f_predict = function(user="Apple"){

  print(user)
  sql = sprintf("select * from my_accel where user = '%s';", user)
  rs = dbSendQuery(con, sql)
  data = fetch(rs, n=-1)
  huh = dbHasCompleted(rs)
  dbClearResult(rs)

  vars = names(data)[grepl("xyz", names(data))]

  test_data = data.frame(data[, names(data) %in% vars],
                           class = as.factor(data$type))

  selected_columns = c("xyz_mean", "xyz_PSD_1", "xyz_PSD_3", "xyz_PSD_6", "xyz_PSD_10", "class")
  test_data = test_data[, selected_columns]
  
  print(head(test_data))
  record_pred = predict(mod, test_data)
  probility_of_pd = mean(record_pred == "PD")
  print(probility_of_pd)
  predict_result = ifelse(probility_of_pd > 0.5, "PD", "Control")
  predict_result
}

#on.exit(dbDisconnect(con))

