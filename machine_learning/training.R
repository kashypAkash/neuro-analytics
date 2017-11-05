library(dplyr)
library(ggplot2)
library(GGally)
library(MASS)
library(e1071)
library(corrplot)

setwd("/Users/longnguyen/Documents/295/neuro-analytics/machine_learning")

users = c("APPLE", "CHERRY", "CROCUS", "DAFODIL", 
          "DAISY", "FLOX", "IRIS", "LILY",
          "MAPLE", "ORANGE", "ORCHID", "PEONY", "ROSE",
          "SUNFLOWER", "SWEETPEA", "VIOLET")
csv_data = "csv_data"
compress_data = "compress_data"
train_users_csv = file.path(csv_data, "train_users.csv")
df_train_users = read.csv(train_users_csv, stringsAsFactors = FALSE)

f_accuracy = function(pred, actual) {
  mean(pred == actual) * 100
}

load(file = file.path(compress_data, paste0("accel_by_hour_xyz_all.rda")))

load(file = file.path(compress_data, paste0("df_gps_day_hour_distance_all.rda")))

f_filter_df_accel = function(gps_day_hour_distance_row) {
  print(gps_day_hour_distance_row)
  df_accel_by_hour_xyz_all$user == gps_day_hour_distance_row[5] &
                    as.character(df_accel_by_hour_xyz_all$date) == gps_day_hour_distance_row[1] &
                    df_accel_by_hour_xyz_all$hour == gps_day_hour_distance_row[2]
  
}

MAX_DISTANCE_THRESHOLD = 5000

valid_gps_index = df_gps_day_hour_distance_all$max_distance <= MAX_DISTANCE_THRESHOLD
df_valid_gps_distance = df_gps_day_hour_distance_all[valid_gps_index,]
print(paste0("valid gps distance row: ", nrow(df_valid_gps_distance)))

df_accel_filter = NULL
for (i in 1:nrow(df_valid_gps_distance)) {
  selected_index = apply(df_valid_gps_distance[i,], 1, f_filter_df_accel)
  print(i)
  print(sum(selected_index))
  selected_rows = df_accel_by_hour_xyz_all[selected_index,]
  df_accel_filter = rbind(df_accel_filter, selected_rows)
}

table(df_accel_filter$type)
table(df_accel_filter$user, df_accel_filter$type)

#df_accel_filter = df_accel_by_hour_xyz_all

xyz_columns = names(df_accel_filter)[grepl("xyz", names(df_accel_filter))]

df_accel_candidate = data.frame(df_accel_filter[, names(df_accel_filter) %in% xyz_columns],
                         class = as.factor(df_accel_filter$type))

#df_accel_candidate = data.frame(df_accel_by_hour_xyz_all[, names(df_accel_by_hour_xyz_all) %in% xyz_columns],
#                         class = as.factor(df_accel_by_hour_xyz_all$type))
##########

#selected_columns = c("xyz_mean", "xyz_PSD_1", "xyz_PSD_3", "xyz_PSD_6", "xyz_PSD_10", "xyz_mean_sd", "xyz_PSD_1_sd", "xyz_PSD_3_sd", "xyz_PSD_6_sd", "xyz_PSD_10_sd", "class")
selected_columns = c("xyz_mean", "xyz_PSD_1", "xyz_PSD_3", "xyz_PSD_6", "xyz_PSD_10", "xyz_PSD_1_sd", "xyz_PSD_3_sd", "xyz_PSD_6_sd", "xyz_PSD_10_sd", "class")
#selected_columns = c("xyz_mean", "xyz_PSD_1", "xyz_PSD_3", "xyz_PSD_6", "xyz_PSD_10", "class")
#selected_columns = c("xyz_PSD_6", "xyz_PSD_10","xyz_PSD_6_sd", "xyz_PSD_10_sd", "class")

#plot data
ggpairs(data = df_accel_candidate,
        columns = selected_columns,
        aes(color = class),
        title = "Training features")

#tuned = tune(svm, class ~., data = train_data, kernel = "radial",
#              ranges = list(cost = c(0.001, 0.01, 0.1, 1, 10, 100),
#              gamma = c(0.5, 1, 2, 3, 4)), prior = c(1, 1)/2)
#summary(tuned)
#plot(tuned$best.model, train_data, xyz.PSD.3 ~ xyz.PSD.10)
train_data = df_accel_candidate[, selected_columns]

mod = svm(class ~., data = train_data, kernel = "radial", cost = 100, gamma = 4, scale = FALSE)
save(mod, file = file.path(compress_data, paste0("mod", ".rda")))
#load(file = file.path(compress_data, paste0("mod", ".rda")))
tuned = tune.svm(class~., data = train_data, gamma = 10^-2, cost = 10^2, tunecontrol=tune.control(cross=5))
summary(tuned)

library(caret)
library(caTools)
control = trainControl(method = "cv", number = 5, savePredictions = TRUE, classProbs = TRUE)
parameterGrid = expand.grid(mtry = c(2,3,4,5))
modelRandome = train(class ~.,
                     data = train_data,
                     method = "rf",
                     trControl = control,
                     tuneGrid = parameterGrid
)
#save(modelRandome, file = file.path(compress_data, paste0("modelRandome", ".rda")))
#load(file = file.path(compress_data, paste0("modelRandome", ".rda")))

#print(mod)
#plot(mod, train_data, xyz_PSD.6 ~ xyz_PSD.10)
#table(mod$class, train_data$class)
users = unique(df_accel_by_hour_xyz_all$user)

probability_of_pd = vector(length=length(users))
predict_result = vector(length=length(users))
actual_result = vector(length=length(users))

for (i in 1:length(users)) {
  print(users[i])
  #predict_user_index = df_accel_by_hour_xyz_all$user == users[i]
  predict_user_index = df_accel_filter$user == users[i]
  train_data = df_accel_candidate[!predict_user_index, selected_columns]
  test_data = df_accel_candidate[predict_user_index, selected_columns]
  #mod = svm(class ~., data = train_data, kernel = "radial", cost = 100, gamma = 4, scale = FALSE)
  #record_pred = predict(mod, test_data)
  record_pred = predict(modelRandome, test_data)
  single_user_probability_of_pd = mean(record_pred == "PD")
  single_user_predict_result = ifelse(single_user_probability_of_pd > 0.5, "PD", "Control")
  print(single_user_predict_result)
  probability_of_pd[i] = single_user_probability_of_pd
  predict_result[i] = single_user_predict_result
  actual_result[i] = unique(as.character(df_accel_candidate$class[predict_user_index]))
  print(table(record_pred, df_accel_candidate[predict_user_index, ]$class))
}

f_accuracy(predict_result, actual_result)
data.frame(users, probability_of_pd, predict_result, actual_result)

#plot single user
  user = users[3]
  #user_index = df_accel_by_hour_xyz_all$user == user
  user_index = df_accel_filter$user == user
  ggpairs(data = df_accel_candidate[user_index, ],
          columns = 5:8,
          aes(color = class),
          title = user)
#plot df_accel_candidate for each pair of features
  ggplot(data = df_accel_candidate,
         aes(x = xyz_PSD_3, y = xyz_PSD_10)) +
         geom_point(aes(color = class))
