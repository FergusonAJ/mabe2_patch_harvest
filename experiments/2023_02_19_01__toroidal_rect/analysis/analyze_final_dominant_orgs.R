rm(list = ls())

source('./shared_config.R')

# Load the data
filename = '../data/combined_final_dominant_data.csv'
if(!file.exists(filename)){
  cat('Error! Data file does not exist: ', filename)
  cat(' Exiting!\n')
  quit()
}
df = read.csv('../data/combined_final_dominant_data.csv')
df$nutrients_consumed = df$nutrients_consumed_mean
df$moves_off_path = df$moves_off_path_mean
df$base_score = df$nutrients_consumed - df$moves_off_path
df$total_nutrients = round(130 * df$base_score / log(df$merit, base = 2))
# Extract total nutrients assuming *some* replicates had a positive score
for(map_idx in unique(df$map_idx)){
  map_mask = df$map_idx == map_idx
  total_nutrients = max(df[map_mask,]$total_nutrients)
  df[map_mask,]$total_nutrients = total_nutrients
}

df$task_quality = df$base_score / df$total_nutrients
df$coverage = df$nutrients_consumed / df$total_nutrients
if(sum(df$base_score < 0) > 0){
  df[df$base_score < 0,]$task_quality = 0
}
if(sum(df$nutrients_consumed == 0) > 0){
  df[df$nutrients_consumed == 0,]$coverage = 0
}
cat('File loaded: ', filename, '\n')

# Group data just by seed
df_grouped = dplyr::group_by(df, seed)
df_summary = dplyr::summarize(df_grouped, 
                              merit_mean = mean(merit), 
                              merit_median = median(merit),
                              nutrients_consumed_mean = mean(nutrients_consumed),
                              nutrients_consumed_median = median(nutrients_consumed),
                              nutrients_consumed_sd = sd(nutrients_consumed),
                              moves_off_path_mean = mean(moves_off_path),
                              moves_off_path_median = median(moves_off_path),
                              moves_off_path_sd = sd(moves_off_path),
                              base_score_mean = mean(base_score),
                              base_score_median = median(base_score),
                              base_score_sd = sd(base_score),
                              task_quality_mean = mean(task_quality),
                              task_quality_median = median(task_quality),
                              task_quality_max = max(task_quality),
                              task_quality_min = min(task_quality),
                              task_quality_sd = sd(task_quality),
                              coverage_mean = mean(coverage),
                              coverage_median = median(coverage),
                              coverage_max = max(coverage),
                              coverage_min = min(coverage),
                              coverage_sd = sd(coverage)
                              )

# Group data by seed AND map index
df_map_grouped = dplyr::group_by(df, seed, map_idx)
df_map_summary = dplyr::summarize(df_map_grouped, 
                              merit_mean = mean(merit), 
                              merit_median = median(merit),
                              merit_sd = sd(merit),
                              nutrients_consumed_mean = mean(nutrients_consumed),
                              nutrients_consumed_median = median(nutrients_consumed),
                              nutrients_consumed_sd = sd(nutrients_consumed),
                              moves_off_path_mean = mean(moves_off_path),
                              moves_off_path_median = median(moves_off_path),
                              moves_off_path_sd = sd(moves_off_path),
                              base_score_mean = mean(base_score),
                              base_score_median = median(base_score),
                              base_score_sd = sd(base_score)
                              )
cat('Data grouped and summarized.\n')


# Create new column that is the seed's order based on merit median and sort
df_summary = dplyr::arrange(df_summary, merit_median)
df_summary$seed_order = 1:nrow(df_summary)
# Make map of seed -> its index in the ordering
seed_order_map = df_summary$seed_order
names(seed_order_map) = df_summary$seed

# Set seed order for raw data
df$seed_order = seed_order_map[as.character(df$seed)]
# Set seed order for seed + map_idx summary
df_map_summary$seed_order = seed_order_map[as.character(df_map_summary$seed)]
cat ('Data ordered.\n')

# Save data to disk
if(!dir.exists(processed_data_dir)){
  dir.create(processed_data_dir)
}
write.csv(df, get_final_dom_processed_data_filename(), row.names = F)
write.csv(df_summary, get_final_dom_processed_summary_filename(), row.names = F)
write.csv(df_map_summary, get_final_dom_processed_map_summary_filename(), row.names = F)





# Find the top N seeds
num_seeds = nrow(df_summary)
top_seeds = 10 
cutoff_val = sort(df_summary$merit_mean)[(num_seeds-top_seeds + 1)]
df_top = df_summary[df_summary$merit_mean >= cutoff_val,]
cat('Here are the top ', top_seeds, ' seeds:\n')
print(df_top[order(df_top$merit_mean, decreasing = T),])

