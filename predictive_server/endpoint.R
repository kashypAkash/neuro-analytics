library(RMySQL)
library(MASS)
library(dplyr)
library(scales)


source("~/config.R")
setwd(predictiveDirectory)

model_dir = "model"
#load(file = file.path(model_dir, paste0("mod", ".rda")))
load(file = file.path(model_dir, paste0("modelRandome", ".rda")))

f_root_mean_square = function(x, y, z) {
  sqrt((x^2 + y^2 + z^2)/3)
}

#* @get /predict
f_predict = function(email_id="Apple", result_id) {
  print(paste0("email_id: ", email_id, ", result_id: ", result_id))
  
  con = dbConnect(RMySQL::MySQL(),
                  user=db_user, password=db_password,
                  dbname=db_name, host=db_host)
  #sql = sprintf("select * from save_accel where user_name = '%s';", user)
  sql = sprintf("select * from acceleration where email_id = '%s' and result_id = %s;", email_id, result_id)
  rs = dbSendQuery(con, sql)
  data = fetch(rs, n=-1)
  huh = dbHasCompleted(rs)
  dbClearResult(rs)
  
  df_accel = data %>%
    filter(time != "time") %>%
    mutate(x_mean = as.numeric(x_mean),
           x_absolute_deviation = as.numeric(x_absolute_deviation),
           x_standard_deviation = as.numeric(x_standard_deviation),
           x_max_deviation = as.numeric(x_max_deviation),
           x_PSD_1 = as.numeric(x_PSD_1),
           x_PSD_3 = as.numeric(x_PSD_3),
           x_PSD_6 = as.numeric(x_PSD_6),
           x_PSD_10 = as.numeric(x_PSD_10),
           y_mean = as.numeric(y_mean),
           y_absolute_deviation = as.numeric(y_absolute_deviation),
           y_standard_deviation = as.numeric(y_standard_deviation),
           y_max_deviation = as.numeric(y_max_deviation),
           y_PSD_1 = as.numeric(y_PSD_1),
           y_PSD_3 = as.numeric(y_PSD_3),
           y_PSD_6 = as.numeric(y_PSD_6),
           y_PSD_10 = as.numeric(y_PSD_10),
           z_mean = as.numeric(z_mean),
           z_absolute_deviation = as.numeric(z_absolute_deviation),
           z_standard_deviation = as.numeric(z_standard_deviation),
           z_max_deviation = as.numeric(z_max_deviation),
           z_PSD_1 = as.numeric(z_PSD_1),
           z_PSD_3 = as.numeric(z_PSD_3),
           z_PSD_6 = as.numeric(z_PSD_6),
           z_PSD_10 = as.numeric(z_PSD_10),
           daytime_orig = as.character(time),
           day = sapply(daytime_orig, function(x) strsplit(x, " ")[[1]][1]),
           time_char = sapply(daytime_orig, function(x) strsplit(x, " ")[[1]][2]),
           time = as.POSIXct(time_char, format = "%H:%M:%S"),
           hour = as.numeric(sapply(time_char, function(x) strsplit(x, ":")[[1]][1])),
           minute = as.numeric(sapply(time_char, function(x) strsplit(x, ":")[[1]][2]))) %>%
    select(-daytime_orig, -time_char)  
  
  df_accel_by_hour = df_accel %>%
    group_by(day, hour, minute) %>%
    summarise(n.count = length(hour),
              x_mean_sd = sd(x_mean),
              x_PSD_1_sd = sd(x_PSD_1),
              x_PSD_3_sd = sd(x_PSD_3),
              x_PSD_6_sd = sd(x_PSD_6),
              x_PSD_10_sd = sd(x_PSD_10),
              x_mean = mean(x_mean),
              x_absolute_deviation = mean(x_absolute_deviation),
              x_standard_deviation = mean(x_standard_deviation),
              x_max_deviation = mean(x_max_deviation),
              x_PSD_1 = mean(x_PSD_1),
              x_PSD_3 = mean(x_PSD_3),
              x_PSD_6 = mean(x_PSD_6),
              x_PSD_10 = mean(x_PSD_10),
              y_mean_sd = sd(y_mean),
              y_PSD_1_sd = sd(y_PSD_1),
              y_PSD_3_sd = sd(y_PSD_3),
              y_PSD_6_sd = sd(y_PSD_6),
              y_PSD_10_sd = sd(y_PSD_10),
              y_mean = mean(y_mean),
              y_absolute_deviation = mean(y_absolute_deviation),
              y_standard_deviation = mean(y_standard_deviation),
              y_max_deviation = mean(y_max_deviation),
              y_PSD_1 = mean(y_PSD_1),
              y_PSD_3 = mean(y_PSD_3),
              y_PSD_6 = mean(y_PSD_6),
              y_PSD_10 = mean(y_PSD_10),
              z_mean_sd = sd(z_mean),
              z_PSD_1_sd = sd(z_PSD_1),
              z_PSD_3_sd = sd(z_PSD_3),
              z_PSD_6_sd = sd(z_PSD_6),
              z_PSD_10_sd = sd(z_PSD_10),
              z_mean = mean(z_mean),
              z_absolute_deviation = mean(z_absolute_deviation),
              z_standard_deviation = mean(z_standard_deviation),
              z_max_deviation = mean(z_max_deviation),
              z_PSD_1 = mean(z_PSD_1),
              z_PSD_3 = mean(z_PSD_3),
              z_PSD_6 = mean(z_PSD_6),
              z_PSD_10 = mean(z_PSD_10)
    ) %>%
    filter(n.count >= 10) %>% 
    mutate(date = as.POSIXct(day, format = "%Y-%m-%d")) %>%
    ungroup() %>%
    select(-c(n.count, day))
  
  df_accel_by_hour_xyz = df_accel_by_hour %>%
    mutate(
      xyz_mean = f_root_mean_square(x_mean, y_mean, z_mean), 
      xyz_absolute_deviation = f_root_mean_square(x_absolute_deviation, y_absolute_deviation, z_absolute_deviation),
      xyz_standard_deviation = f_root_mean_square(x_standard_deviation, y_standard_deviation, z_standard_deviation),
      xyz_max_deviation = f_root_mean_square(x_max_deviation, y_max_deviation, z_max_deviation),
      xyz_PSD_1 = f_root_mean_square(x_PSD_1, y_PSD_1, z_PSD_1),
      xyz_PSD_3 = f_root_mean_square(x_PSD_3, y_PSD_3, z_PSD_3),
      xyz_PSD_6 = f_root_mean_square(x_PSD_6, y_PSD_6, z_PSD_6),
      xyz_PSD_10 = f_root_mean_square(x_PSD_10, y_PSD_10, z_PSD_10),
      xyz_mean_sd = f_root_mean_square(x_mean_sd, y_mean_sd, z_mean_sd), 
      xyz_PSD_1_sd = f_root_mean_square(x_PSD_1_sd, y_PSD_1_sd, z_PSD_1_sd),
      xyz_PSD_3_sd = f_root_mean_square(x_PSD_3_sd, y_PSD_3_sd, z_PSD_3_sd),
      xyz_PSD_6_sd = f_root_mean_square(x_PSD_6_sd, y_PSD_6_sd, z_PSD_6_sd),
      xyz_PSD_10_sd = f_root_mean_square(x_PSD_10_sd, y_PSD_10_sd, z_PSD_10_sd)
    ) %>%
    select(starts_with("xyz"), date, hour, minute)

  selected_columns = c("xyz_mean", "xyz_PSD_1", "xyz_PSD_3", "xyz_PSD_6", "xyz_PSD_10", "xyz_PSD_1_sd", "xyz_PSD_3_sd", "xyz_PSD_6_sd", "xyz_PSD_10_sd")
  test_data = df_accel_by_hour_xyz[, selected_columns]
  
  print(head(test_data))
  record_pred = predict(modelRandome, test_data)
  probility_of_pd = mean(record_pred == "PD")
  print(probility_of_pd)
  predict_result = ifelse(probility_of_pd > 0.5, "PD", "Control")
  
  #update predict result to result table
  sql = sprintf("update result set classification = '%s' where email_id = '%s' and id = %s;", predict_result, email_id, result_id)
  rs = dbSendQuery(con, sql)
  dbClearResult(rs)
  
  dbDisconnect(con)
  predict_result
}

#on.exit(dbDisconnect(con))

