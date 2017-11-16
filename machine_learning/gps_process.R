library(dplyr)
library(ggplot2)
library(geosphere)

source("~/config.R")
setwd(workingDirectory)

users = c("APPLE", "CHERRY", "CROCUS", "DAFODIL", 
          "DAISY", "FLOX", "IRIS", "LILY",
          "MAPLE", "ORANGE", "ORCHID", "PEONY", "ROSE",
          "SUNFLOWER", "SWEETPEA", "VIOLET")
csv_data = "csv_data"
compress_data = "compress_data"

train_users_csv = file.path(csv_data, "train_users.csv")
df_train_users = read.csv(train_users_csv, stringsAsFactors = FALSE)
df_gps_day_hour_distance_all = NULL

#load(file = file.path(compress_data, paste0("df_gps_ORANGE.rda")))

#user = "APPLE"
for (user in users) {
  gps_file = paste0(user, "_gps.csv")
  print(gps_file)
  df_gps = read.csv(file.path(csv_data, gps_file), stringsAsFactors = FALSE)
  head(df_gps)

  df_gps = df_gps %>%
    filter(time != "time") %>%
    mutate(latitude = as.numeric(latitude),
           longitude = as.numeric(longitude),
           daytime_orig = as.character(time),
           day = sapply(daytime_orig, function(x) strsplit(x, " ")[[1]][1]),
           time_char = sapply(daytime_orig, function(x) strsplit(x, " ")[[1]][2]),
           hour = as.numeric(sapply(time_char, function(x) strsplit(x, ":")[[1]][1])),
           minute = as.numeric(sapply(time_char, function(x) strsplit(x, ":")[[1]][2]))) %>%
    select(-diffSecs, -altitude, -daytime_orig, -time_char, -time)
  
  invalid_gps_index = (df_gps$longitude > 360)  | (df_gps$latitude > 306)
  df_gps = df_gps[!invalid_gps_index,]
  
  save(df_gps, file = file.path(compress_data, paste0("df_gps_", user, ".rda")))
  
  head(df_gps)
  
  df_gps_day_hour_distance = df_gps %>%
    group_by(day, hour) %>%
    summarise(
      n=length(hour)
    )
  
  head(df_gps_day_hour_distance)
  
  f_max_distance = function(row) {
    max(distm(df_gps[(df_gps$day == row[1])  & (df_gps$hour == row[2]),c(2,1)]))
  }
  
  v_max_distance = vector('numeric', nrow(df_gps_day_hour_distance))
  
  for (i in 1:nrow(df_gps_day_hour_distance)) {
    max_distance = apply(df_gps_day_hour_distance[i,], 1, f_max_distance)
    print (i)
    print(max_distance)
    v_max_distance[i] = max_distance
  }

  df_gps_day_hour_distance$max_distance = v_max_distance
  
  user_index = toupper(df_train_users$Name) == user
  df_gps_day_hour_distance$user = df_train_users$Name[user_index]
  
  save(df_gps_day_hour_distance, 
       file = file.path(compress_data, paste0("df_gps_day_hour_distance_", user, ".rda")))
  
  print(user)
}

total_row = 0
for (user in users) {
  load(file = file.path(compress_data, paste0("df_gps_day_hour_distance_", user, ".rda")))
  total_row = total_row + nrow(df_gps_day_hour_distance)
  df_gps_day_hour_distance_all = rbind(df_gps_day_hour_distance_all, df_gps_day_hour_distance)
}
print(total_row)
save(df_gps_day_hour_distance_all, 
     file = file.path(compress_data, paste0("df_gps_day_hour_distance_all.rda")))
