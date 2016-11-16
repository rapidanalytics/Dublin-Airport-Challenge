########################################################
# 1. Import packages and functions
########################################################
import pandas as pd
import numpy as np
from sklearn.metrics import mean_squared_error


########################################################
# 2. Define variables which we will use later in the script
########################################################
s_root_folder = 'S:/Public/ADA Team/Hackathon/'
s_train_file = 'train.csv'
s_test_file = 'test.csv'
l_parse_date_cols = ['dt_prediction_date', 'dt_target_date', 'dt_flight_date']
l_target_cols = ['num_pax_000_014_mins_before_sdt', 'num_pax_015_029_mins_before_sdt', 'num_pax_030_044_mins_before_sdt', 'num_pax_045_059_mins_before_sdt', 'num_pax_060_074_mins_before_sdt', 'num_pax_075_089_mins_before_sdt', 'num_pax_090_104_mins_before_sdt', 'num_pax_105_119_mins_before_sdt',  'num_pax_120_134_mins_before_sdt', 'num_pax_135_149_mins_before_sdt', 'num_pax_150_164_mins_before_sdt', 'num_pax_165_179_mins_before_sdt',  'num_pax_180_194_mins_before_sdt', 'num_pax_195_209_mins_before_sdt', 'num_pax_210_224_mins_before_sdt', 'num_pax_225_239_mins_before_sdt', 'num_pax_240plus_mins_before_sdt']


########################################################
# 3. Define functions which we will use later in the script
########################################################
def check_for_negatives_in_pred(df_pred, l_cols_to_range_over):
	'''A negative number of passengers turning up in a 15 minute window is not valid, so we set any negatives predictions to zero'''
	df_pred[df_pred[l_cols_to_range_over] < 0] = 0
	return df_pred

def calculate_score(df_target_cases, df_predictions):
	'''Root-mean-squared error is the chosen error metric. This function calculates and returns the root-mean-squared error'''
	f_rmse = np.sqrt(mean_squared_error(df_target_cases, df_predictions))
	return f_rmse


###############################################
# 4. Read in csv file and parse dates. Also generate dataframe with the target cases ordered by id
###############################################
df_raw_data_amt = pd.read_csv(s_root_folder + s_train_file, parse_dates = l_parse_date_cols)
df_target_cases = df_raw_data_amt[df_raw_data_amt['cat_case_type'] == 'Target'].set_index('id').sort_index()[l_target_cols]


############################################################################################################################
# 5. For demonstration purposes, we will make a prediction for each ID based only on the average passenger profile from the five most recent historical flight cases prior to the prediction date
############################################################################################################################
# Rank the explanatory cases for each id by most recent to prediction date
df_raw_data_amt['id_rank'] = df_raw_data_amt[df_raw_data_amt['cat_case_type'] == 'Expl'].groupby('id')['dt_flight_date'].rank(ascending = False)

# Filter the dataset to just include the five most recent historical flight cases for each id
df_expl_data = df_raw_data_amt[df_raw_data_amt['id_rank'] <= 5][['id'] + l_target_cols]

# Average these cases as a rudimentary prediction
df_avg_prediction = df_expl_data.groupby('id').mean()

# Although we can't have negative values for this approach, put it through the check_for_negatives_in_pred function anyway
df_avg_prediction = check_for_negatives_in_pred(df_avg_prediction, l_target_cols)


# Note that not all target cases have historical flight data. In the example approach we are demonstrating, for these cases we make a prediction of 0
# However, more complete models should also attempt to generate accurate predictions for these cases 
# E.g. by looking for other flights with similar attributes such as destination, time periods, behavioural attributes, etc.
# If you wish to approve this challenge by other valid means, you are welcome to do so

# Get the IDs that have no historic flight explanatory cases
b_mask = np.in1d(df_raw_data_amt[df_raw_data_amt['cat_case_type'] == 'Target']['id'].unique(), df_avg_prediction.index, assume_unique = True)
arr_no_history_id = df_raw_data_amt[df_raw_data_amt['cat_case_type'] == 'Target']['id'].unique()[~b_mask]

# Create a new dataframe for these IDs and fill with zero
df_zero_preds = pd.DataFrame(index = arr_no_history_id, columns = l_target_cols)
df_zero_preds = df_zero_preds.fillna(0)

# Concatendate the two dataframes and sort by ID
df_combined_predictions = pd.concat([df_avg_prediction, df_zero_preds], ignore_index = False).sort_index()


###############################################
# 6. Pass the predictions through our error function to get the model scroe
###############################################
f_rmse = calculate_score(df_target_cases, df_combined_predictions)
print('The root-mean-squared error is ' + str(f_rmse))


###############################################
# 7. Apply the same approach to the test data and save the predictions to file for submission
###############################################
df_raw_data_amt = pd.read_csv(s_root_folder + s_test_file, parse_dates = l_parse_date_cols)
df_target_cases = df_raw_data_amt[df_raw_data_amt['cat_case_type'] == 'Target'].set_index('id').sort_index()[l_target_cols]

df_raw_data_amt['id_rank'] = df_raw_data_amt[df_raw_data_amt['cat_case_type'] == 'Expl'].groupby('id')['dt_flight_date'].rank(ascending = False)
df_expl_data = df_raw_data_amt[df_raw_data_amt['id_rank'] <= 5][['id'] + l_target_cols]
df_avg_prediction = df_expl_data.groupby('id').mean()
df_avg_prediction = check_for_negatives_in_pred(df_avg_prediction, l_target_cols)

b_mask = np.in1d(df_raw_data_amt[df_raw_data_amt['cat_case_type'] == 'Target']['id'].unique(), df_avg_prediction.index, assume_unique = True)
arr_no_history_id = df_raw_data_amt[df_raw_data_amt['cat_case_type'] == 'Target']['id'].unique()[~b_mask]
df_zero_preds = pd.DataFrame(index = arr_no_history_id, columns = l_target_cols)
df_zero_preds = df_zero_preds.fillna(0)

df_combined_predictions = pd.concat([df_avg_prediction, df_zero_preds], ignore_index = False).sort_index()
df_combined_predictions.to_csv(s_root_folder + "model_submission.csv")