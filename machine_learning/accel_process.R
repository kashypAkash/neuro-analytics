library(dplyr)
library(ggplot2)
library(scales)

source("/tmp/config.R")
setwd(workingDirectory)

users = c("APPLE", "CHERRY", "CROCUS", "DAFODIL", 
          "DAISY", "FLOX", "IRIS", "LILY",
          "MAPLE", "ORANGE", "ORCHID", "PEONY", "ROSE",
          "SUNFLOWER", "SWEETPEA", "VIOLET")
csv_data = "csv_data"
compress_data = "compress_data"
train_users_csv = file.path(csv_data, "train_users.csv")
df_train_users = read.csv(train_users_csv, stringsAsFactors = FALSE)
f_root_mean_square = function(x, y, z) {
  sqrt((x^2 + y^2 + z^2)/3)
}
#----------------------------------------------------------------------
#user = "APPLE"
for (user in users) {
  
  accel_csv = paste0(user, "_accel.csv")
  df_accel_temp = read.csv(file.path(csv_data, accel_file), stringsAsFactors = FALSE)
  df_accel = df_accel_temp %>%
    filter(time != "time") %>%
    mutate(x.mean = as.numeric(x.mean),
           x.absolute.deviation = as.numeric(x.absolute.deviation),
           x.standard.deviation = as.numeric(x.standard.deviation),
           x.max.deviation = as.numeric(x.max.deviation),
           x.PSD.1 = as.numeric(x.PSD.1),
           x.PSD.3 = as.numeric(x.PSD.3),
           x.PSD.6 = as.numeric(x.PSD.6),
           x.PSD.10 = as.numeric(x.PSD.10),
           y.mean = as.numeric(y.mean),
           y.absolute.deviation = as.numeric(y.absolute.deviation),
           y.standard.deviation = as.numeric(y.standard.deviation),
           y.max.deviation = as.numeric(y.max.deviation),
           y.PSD.1 = as.numeric(y.PSD.1),
           y.PSD.3 = as.numeric(y.PSD.3),
           y.PSD.6 = as.numeric(y.PSD.6),
           y.PSD.10 = as.numeric(y.PSD.10),
           z.mean = as.numeric(z.mean),
           z.absolute.deviation = as.numeric(z.absolute.deviation),
           z.standard.deviation = as.numeric(z.standard.deviation),
           z.max.deviation = as.numeric(z.max.deviation),
           z.PSD.1 = as.numeric(z.PSD.1),
           z.PSD.3 = as.numeric(z.PSD.3),
           z.PSD.6 = as.numeric(z.PSD.6),
           z.PSD.10 = as.numeric(z.PSD.10),
           daytime_orig = as.character(time),
           day = sapply(daytime_orig, function(x) strsplit(x, " ")[[1]][1]),
           time_char = sapply(daytime_orig, function(x) strsplit(x, " ")[[1]][2]),
           time = as.POSIXct(time_char, format = "%H:%M:%S"),
           hour = as.numeric(sapply(time_char, function(x) strsplit(x, ":")[[1]][1])),
           minute = as.numeric(sapply(time_char, function(x) strsplit(x, ":")[[1]][2]))) %>%
    select(-daytime_orig, -time_char)  
  
  selected_user_index = toupper(df_train_users$Name) == user
  df_accel$user = df_train_users$Name[selected_user_index]
  df_accel$type = df_train_users$Type[selected_user_index]
  save(df_accel, file = file.path(compress_data, paste0(user, "_accel", ".rda")))
  
  
  df_accel_by_hour = df_accel %>%
    group_by(day, hour) %>%
    summarise(n.count = length(hour),
              x.mean.sd = sd(x.mean),
              x.PSD.1.sd = sd(x.PSD.1),
              x.PSD.3.sd = sd(x.PSD.3),
              x.PSD.6.sd = sd(x.PSD.6),
              x.PSD.10.sd = sd(x.PSD.10),
              x.mean = mean(x.mean),
              x.absolute.deviation = mean(x.absolute.deviation),
              x.standard.deviation = mean(x.standard.deviation),
              x.max.deviation = mean(x.max.deviation),
              x.PSD.1 = mean(x.PSD.1),
              x.PSD.3 = mean(x.PSD.3),
              x.PSD.6 = mean(x.PSD.6),
              x.PSD.10 = mean(x.PSD.10),
              y.mean.sd = sd(y.mean),
              y.PSD.1.sd = sd(y.PSD.1),
              y.PSD.3.sd = sd(y.PSD.3),
              y.PSD.6.sd = sd(y.PSD.6),
              y.PSD.10.sd = sd(y.PSD.10),
              y.mean = mean(y.mean),
              y.absolute.deviation = mean(y.absolute.deviation),
              y.standard.deviation = mean(y.standard.deviation),
              y.max.deviation = mean(y.max.deviation),
              y.PSD.1 = mean(y.PSD.1),
              y.PSD.3 = mean(y.PSD.3),
              y.PSD.6 = mean(y.PSD.6),
              y.PSD.10 = mean(y.PSD.10),
              z.mean.sd = sd(z.mean),
              z.PSD.1.sd = sd(z.PSD.1),
              z.PSD.3.sd = sd(z.PSD.3),
              z.PSD.6.sd = sd(z.PSD.6),
              z.PSD.10.sd = sd(z.PSD.10),
              z.mean = mean(z.mean),
              z.absolute.deviation = mean(z.absolute.deviation),
              z.standard.deviation = mean(z.standard.deviation),
              z.max.deviation = mean(z.max.deviation),
              z.PSD.1 = mean(z.PSD.1),
              z.PSD.3 = mean(z.PSD.3),
              z.PSD.6 = mean(z.PSD.6),
              z.PSD.10 = mean(z.PSD.10)
    ) %>%
    filter(n.count >= 10) %>% 
    mutate(date = as.POSIXct(day, format = "%Y-%m-%d")) %>%
    ungroup() %>%
    select(-c(n.count, day))
  
  selected_user_index = toupper(df_train_users$Name) == user
  df_accel_by_hour$user = df_train_users$Name[selected_user_index]
  df_accel_by_hour$type = df_train_users$Type[selected_user_index]
  save(df_accel_by_hour, file = file.path(compress_data, paste0(user, "_accel_by_hour", ".rda")))
  
  df_accel_by_hour_xyz = df_accel_by_hour %>%
    mutate(
      xyz_mean = f_root_mean_square(x.mean, y.mean, z.mean), 
      xyz_absolute_deviation = f_root_mean_square(x.absolute.deviation, y.absolute.deviation, z.absolute.deviation),
      xyz_standard_deviation = f_root_mean_square(x.standard.deviation, y.standard.deviation, z.standard.deviation),
      xyz_max_deviation = f_root_mean_square(x.max.deviation, y.max.deviation, z.max.deviation),
      xyz_PSD_1 = f_root_mean_square(x.PSD.1, y.PSD.1, z.PSD.1),
      xyz_PSD_3 = f_root_mean_square(x.PSD.3, y.PSD.3, z.PSD.3),
      xyz_PSD_6 = f_root_mean_square(x.PSD.6, y.PSD.6, z.PSD.6),
      xyz_PSD_10 = f_root_mean_square(x.PSD.10, y.PSD.10, z.PSD.10),
      xyz_mean_sd = f_root_mean_square(x.mean.sd, y.mean.sd, z.mean.sd), 
      xyz_PSD_1_sd = f_root_mean_square(x.PSD.1.sd, y.PSD.1.sd, z.PSD.1.sd),
      xyz_PSD_3_sd = f_root_mean_square(x.PSD.3.sd, y.PSD.3.sd, z.PSD.3.sd),
      xyz_PSD_6_sd = f_root_mean_square(x.PSD.6.sd, y.PSD.6.sd, z.PSD.6.sd),
      xyz_PSD_10_sd = f_root_mean_square(x.PSD.10.sd, y.PSD.10.sd, z.PSD.10.sd)
    ) %>%
    select(starts_with("xyz"), date, hour)
  
  selected_user_index = toupper(df_train_users$Name) == user
  df_accel_by_hour_xyz$user = df_train_users$Name[selected_user_index]
  df_accel_by_hour_xyz$type = df_train_users$Type[selected_user_index]
  
  save(df_accel_by_hour_xyz, file = file.path(compress_data, paste0(user, "_accel_by_hour_xyz", ".rda")))
  print(paste0("Accel Proccess finished: " ,user))
}


df_accel_by_hour_xyz_all = NULL
for (user in users) {
  load(file = file.path(compress_data, paste0(user, "_accel_by_hour_xyz", ".rda")))
  df_accel_by_hour_xyz_all = rbind(df_accel_by_hour_xyz_all, df_accel_by_hour_xyz)
}
save(df_accel_by_hour_xyz_all, file = file.path(compress_data, paste0("accel_by_hour_xyz_all.rda")))

