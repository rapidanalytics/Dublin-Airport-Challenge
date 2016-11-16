########################################################
# 1. Import packages and functions
########################################################
library(dplyr)


########################################################
# 2. Define variables which we will use later in the script
########################################################
s_root_folder <- 'S:/Public/ADA Team/Hackathon/'
s_train_file <- 'train.csv'
s_test_file <- 'test.csv'
v_target_cols <- c('num_pax_000_014_mins_before_sdt', 'num_pax_015_029_mins_before_sdt', 'num_pax_030_044_mins_before_sdt', 'num_pax_045_059_mins_before_sdt', 'num_pax_060_074_mins_before_sdt', 'num_pax_075_089_mins_before_sdt', 'num_pax_090_104_mins_before_sdt', 'num_pax_105_119_mins_before_sdt',  'num_pax_120_134_mins_before_sdt', 'num_pax_135_149_mins_before_sdt', 'num_pax_150_164_mins_before_sdt', 'num_pax_165_179_mins_before_sdt',  'num_pax_180_194_mins_before_sdt', 'num_pax_195_209_mins_before_sdt', 'num_pax_210_224_mins_before_sdt', 'num_pax_225_239_mins_before_sdt', 'num_pax_240plus_mins_before_sdt')


########################################################
# 3. Define functions which we will use later in the script
########################################################
check_for_negatives_in_pred <- function(df_pred, v_cols_to_range_over){
	# A negative number of passengers turning up in a 15 minute window is not valid, so we set any negatives predictions to zero
	df_pred[, v_cols_to_range_over][df_pred[, v_cols_to_range_over] < 0] <- 0
	return (df_pred)
}

calculate_score <- function(df_target_cases, df_predictions, v_target_cols)
{
	# Root-mean-squared error is the chosen error metric. This function calculates and returns the root-mean-squared error
	error <- df_target_cases[, v_target_cols] - df_predictions[,v_target_cols]
	return(sqrt(mean(error^2)))
}

###############################################
# 4. Read in csv file and parse dates. Also generate dataframe with the target cases ordered by id
###############################################
setwd(s_root_folder)
df_raw_data_amt <- read.csv(s_train_file, header = TRUE, sep = ",")

df_raw_data_amt$dt_target_date <- as.Date(df_raw_data_amt$dt_target_date, format = "%Y-%m-%d")
df_raw_data_amt$dt_prediction_date <- as.Date(df_raw_data_amt$dt_prediction_date, format = "%Y-%m-%d")
df_raw_data_amt$dt_flight_date <- as.Date(df_raw_data_amt$dt_flight_date, format = "%Y-%m-%d")

df_target_cases <- df_raw_data_amt[df_raw_data_amt['cat_case_type'] == 'Target', c("id", v_target_cols)]
df_target_cases <- df_target_cases[order(df_target_cases$id), ]


############################################################################################################################
# 5. For demonstration purposes, we will make a prediction for each ID based only on the average passenger profile from the five most recent historical flight cases prior to the prediction date
############################################################################################################################
# Use only historic flight cases
df_expl_data <- df_raw_data_amt[df_raw_data_amt['cat_case_type'] == 'Expl', ]

# Rank the cases for each id by most recent to prediction date
df_expl_data <- df_expl_data %>% group_by(id) %>% mutate(id_rank = order(dt_flight_date, decreasing=TRUE))

# Filter the dataset to just include the five most recent historical flight cases for each id
df_expl_data <- df_expl_data[df_expl_data['id_rank'] <= 5, c('id', v_target_cols)]

# Average these cases as a rudimentary prediction
df_avg_prediction <- df_expl_data %>% group_by(id) %>% summarise_each(funs(mean))

# Although we can't have negative values for this approach, put it through the check_for_negatives_in_pred function anyway
df_avg_prediction <- check_for_negatives_in_pred(df_avg_prediction, v_target_cols)

# Note that not all target cases have historical flight data. In the example approach we are demonstrating, for these cases we make a prediction of 0
# However, more complete models should also attempt to generate accurate predictions for these cases 
# E.g. by looking for other flights with similar attributes such as destination, time periods, behavioural attributes, etc.
# If you wish to approve this challenge by other valid means, you are welcome to do so

# Get the IDs that have no historic flight explanatory cases
v_no_history_id <- subset(df_target_cases$id, !(df_target_cases$id %in% df_avg_prediction$id))

# Create a new dataframe for these IDs and fill with zero
df_zero_preds <- data.frame(cbind(v_no_history_id, matrix(0, ncol = 17, nrow = length(v_no_history_id))))
colnames(df_zero_preds) <- colnames(df_avg_prediction)

# Combine the two dataframes and sort by ID
df_combined_predictions <- rbind(df_avg_prediction, df_zero_preds)
df_combined_predictions <- df_combined_predictions[order(df_combined_predictions$id), ]


###############################################
# 6. Pass the predictions through our error function to get the model scroe
###############################################
f_rmse <- calculate_score(df_target_cases, df_combined_predictions, v_target_cols)
print(paste('The root-mean-squared error is ', f_rmse, sep = ""))


###############################################
# 7. Apply the same approach to the test data and save the predictions to file for submission
###############################################
df_test_data_amt <- read.csv(s_test_file, header = TRUE, sep = ",")

df_test_data_amt$dt_target_date <- as.Date(df_test_data_amt$dt_target_date, format = "%Y-%m-%d")
df_test_data_amt$dt_prediction_date <- as.Date(df_test_data_amt$dt_prediction_date, format = "%Y-%m-%d")
df_test_data_amt$dt_flight_date <- as.Date(df_test_data_amt$dt_flight_date, format = "%Y-%m-%d")

df_target_cases <- df_test_data_amt[df_test_data_amt['cat_case_type'] == 'Target', c("id", v_target_cols)]
df_target_cases <- df_target_cases[order(df_target_cases$id), ]

df_expl_data <- df_test_data_amt[df_test_data_amt['cat_case_type'] == 'Expl', ]
df_expl_data <- df_expl_data %>% group_by(id) %>% mutate(id_rank = order(dt_flight_date, decreasing=TRUE))
df_expl_data <- df_expl_data[df_expl_data['id_rank'] <= 5, c('id', v_target_cols)]
df_avg_prediction <- df_expl_data %>% group_by(id) %>% summarise_each(funs(mean))
df_avg_prediction <- check_for_negatives_in_pred(df_avg_prediction, v_target_cols)

v_no_history_id <- subset(df_target_cases$id, !(df_target_cases$id %in% df_avg_prediction$id))
df_zero_preds <- data.frame(cbind(v_no_history_id, matrix(0, ncol = 17, nrow = length(v_no_history_id))))
colnames(df_zero_preds) <- colnames(df_avg_prediction)

df_combined_predictions <- rbind(df_avg_prediction, df_zero_preds)
df_combined_predictions <- df_combined_predictions[order(df_combined_predictions$id), ]

write.csv(x = df_combined_predictions, file = paste(s_root_folder, "model_submission.csv", sep = ""), row.names = FALSE)
