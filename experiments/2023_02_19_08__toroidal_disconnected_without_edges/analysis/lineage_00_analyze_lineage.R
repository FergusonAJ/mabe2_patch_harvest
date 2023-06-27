library(dplyr)

source('./shared_config_lineage.R')

lineage_func_00_analyze_lineage = function(seed){
  rep_data_dir = get_lineage_data_dir(seed)
  rep_plot_dir = get_lineage_plot_dir(seed)
  rep_scripts_dir = get_lineage_scripts_dir(seed)
  rep_processed_data_dir = get_lineage_processed_data_dir(seed)
  
  # Load the data
  df = load_lineage_base_data(seed)
  
  # Clean the data
  df = df[!is.na(df$map_idx),] # Remove any null entries
  df$nutrients_consumed = df$nutrients_consumed_mean
  df$moves_off_path = df$moves_off_path_mean
  df$base_score = df$nutrients_consumed - df$moves_off_path
  df$total_nutrients = round(130 * df$base_score / log(df$merit, base = 2))
  
  # Extract total nutrients, assuming *some* replicates had a positive score
  for(map_idx in unique(df$map_idx)){
    map_mask = df$map_idx == map_idx
    total_nutrients = max(df[map_mask,]$total_nutrients, na.rm = T)
    df[map_mask,]$total_nutrients = total_nutrients
  }
  
  # Derive columns
  df$task_quality = df$base_score / df$total_nutrients
  df$coverage = df$nutrients_consumed / df$total_nutrients
  if(sum(df$base_score < 0) > 0){
    df[df$base_score < 0,]$task_quality = 0
  }
  if(sum(df$nutrients_consumed == 0) > 0){
    df[df$nutrients_consumed == 0,]$coverage = 0
  }
  
  
  # Group data just by depth
  df_grouped = dplyr::group_by(df, depth)
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
  cat('Data grouped and summarized.\n')
  
  
  # Create new column that is the depth's order based on merit median and sort
  df_summary = dplyr::arrange(df_summary, merit_median)
  df_summary$depth_order = 1:nrow(df_summary)
  # Make map of depth -> its index in the ordering
  depth_order_map = df_summary$depth_order
  names(depth_order_map) = df_summary$depth
  
  # Set depth order for raw data
  df$depth_order = depth_order_map[as.character(df$depth)]
  cat ('Data ordered.\n')
  
  # Calculate the notable depths (every N steps + jumps in merit)
  notable_depth_step = 50
  notable_depths = seq(0, max(df$depth), notable_depth_step)
  notable_depths = c(notable_depths, max(df$depth))
  notable_depth_merit_threshold = 0.001
  for(depth in 1:max(df$depth)){
    task_quality_diff = df_summary[df_summary$depth == depth,]$task_quality_mean - df_summary[df_summary$depth == (depth - 1),]$task_quality_mean
    if(abs(task_quality_diff) >= notable_depth_merit_threshold){
      notable_depths = c(notable_depths, depth)
    }
  }
  notable_depths = sort(unique(notable_depths))
  
  # Mark notable depths in data frames
  df_summary$is_notable = F
  df_summary[df_summary$depth %in% notable_depths,]$is_notable = T
  df$is_notable = F
  df[df$depth %in% notable_depths,]$is_notable = T
  
  # Save the processed data!
  processed_data_filename = get_lineage_processed_data_filename(seed)
  write.csv(df, processed_data_filename)
  processed_summary_filename = get_lineage_processed_summary_filename(seed)
  write.csv(df_summary, processed_summary_filename)
}