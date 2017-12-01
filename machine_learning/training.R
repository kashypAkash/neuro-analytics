library(dplyr)
library(ggplot2)
library(GGally)
library(MASS)
library(e1071)
library(corrplot)
library(caret)
library(caTools)

source("~/config.R")
setwd(workingDirectory)

users = c("APPLE", "CHERRY", "CROCUS", "DAFODIL", 
          "DAISY", "FLOX", "IRIS", "LILY",
          "MAPLE", "ORANGE", "ORCHID", "PEONY", "ROSE",
          "SUNFLOWER", "SWEETPEA", "VIOLET")
compress_data = "compress_data"

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

#save(df_accel_candidate, file = file.path(compress_data, paste0("df_accel_candidate", ".rda")))
#load(file = file.path(compress_data, paste0("df_accel_candidate", ".rda")))

##########

selected_columns = c("xyz_mean", "xyz_PSD_1", "xyz_PSD_3", "xyz_PSD_6", "xyz_PSD_10", "xyz_PSD_1_sd", "xyz_PSD_3_sd", "xyz_PSD_6_sd", "xyz_PSD_10_sd", "class")


#plot data
ggpairs(data = df_accel_candidate,
        columns = selected_columns,
        aes(color = class),
        title = "Training features")


train_data = df_accel_candidate[, selected_columns]

control = trainControl(method = "cv", number = 5, savePredictions = TRUE, classProbs = TRUE)
parameterGrid = expand.grid(mtry = c(2,3,4,5))

model_weights <- ifelse(train_data$class == "Control",
                        (1/table(train_data$class)[1]) * 0.5 * 1000,
                        (1/table(train_data$class)[2]) * 0.5 * 1000)

#LDA
modelLDA = train(class ~.,
                     data = train_data,
                     method = "lda",
                     trControl = control
)

modelLDA

#QDA
modelQDA = train(class ~.,
                 data = train_data,
                 method = "qda",
                 trControl = control
)

modelQDA

#svmLinear
modelSvmLinear = train(class ~.,
                       data = train_data,
                       method = "svmLinear",
                       trControl = control
)

modelSvmLinear

#svmRadial
modelSvmRadial = train(class ~.,
                 data = train_data,
                 method = "svmRadial",
                 trControl = control
)

modelSvmRadial

#naive_bayes
modelNaiveBayes = train(class ~.,
                       data = train_data,
                       method = "naive_bayes",
                       trControl = control
)

modelNaiveBayes

#k-Nearest Neighbors
modelNearestNeighbors = train(class ~.,
                        data = train_data,
                        method = "knn",
                        trControl = control
)

modelNearestNeighbors

#Random Forest
modelRandome = train(class ~.,
                     data = train_data,
                     method = "rf",
                     weights = model_weights,
                     trControl = control,
                     tuneGrid = parameterGrid
)

modelRandome

#save(modelRandome, file = file.path(compress_data, paste0("modelRandome", ".rda")))
#load(file = file.path(compress_data, paste0("modelRandome", ".rda")))


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
f_accuracy = function(pred, actual) {
  mean(pred == actual) * 100
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
  
#important features
  importance = varImp(modelRandome, scale=FALSE)  
  importance
  ggplot(importance) + geom_bar(stat = "identity", fill = "tomato")
  
#plot df_accel_candidate for two most important features
  ggplot(data = df_accel_candidate,
         aes(x = xyz_mean, y = xyz_PSD_6_sd)) +
         geom_point(aes(color = class))
