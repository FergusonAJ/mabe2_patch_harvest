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
write.csv(df, paste0(processed_data_dir, '/processed_full.csv'))
write.csv(df_summary, paste0(processed_data_dir, '/processed_summary.csv'))

# Plot!
# Raw data, one boxplot per seed, ordered
if(T){
  ggplot(df, aes(x = as.factor(seed_order), y = merit + 0.01)) + 
    geom_boxplot() + 
    scale_y_continuous(trans='log2') + 
    theme(axis.text.x = element_blank()) + 
    theme(axis.ticks.x = element_blank()) + 
    ylab('Merit (log2 scale with zeros shown)') + 
    xlab('Seed (ordered by median merit)')
  ggsave(paste0(plot_dir, 'raw_data__boxplots.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'raw_data__boxplots.pdf'), units = 'in', width = 8, height = 6)
  
  ggplot(df_summary, aes(x = merit_median, y = merit_mean)) + 
    geom_point() +
    geom_abline(aes(slope=1, intercept=0)) +
    scale_y_continuous(trans='log2') +
    scale_x_continuous(trans='log2') +
    xlab('Median merit (log2 scale)') +
    ylab('Mean merit (log2 scale)')
  ggsave(paste0(plot_dir, 'summary__median_vs_mean.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'summary__median_vs_mean.pdf'), units = 'in', width = 8, height = 6)
}
# Data summarized by map
if(T){
  ggplot(df_map_summary, aes(x = as.factor(seed_order), y = merit_mean + 0.1)) + 
    geom_boxplot() +
    scale_y_continuous(trans='log2') + 
    theme(axis.text.x = element_blank()) + 
    theme(axis.ticks.x = element_blank()) + 
    ylab('Merit of each map (log2 scale with zeros shown)') + 
    xlab('Seed (ordered by median merit)') 
  ggsave(paste0(plot_dir, 'map_summary__median.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'map_summary__median.pdf'), units = 'in', width = 8, height = 6)
  
  ggplot(df_map_summary, aes(x = as.factor(seed_order), y = merit_sd)) + 
    geom_point() +
    theme(axis.text.x = element_blank()) + 
    theme(axis.ticks.x = element_blank()) + 
    ylab('Standard variation of merit for each map') + 
    xlab('Seed (ordered by median merit)') 
  ggsave(paste0(plot_dir, 'map_summary__standard_deviation.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'map_summary__standard_deviation.pdf'), units = 'in', width = 8, height = 6)
}
# Plot data distribution to identify potential groups
if(T){
  ggplot(df_summary, aes(x = base_score_mean)) + 
    geom_histogram(binwidth = 25) + 
    geom_jitter(mapping = aes(y = -3), position = position_jitter(height = 2, seed = 10), alpha = 0.2) +
    ylab('Frequency') + 
    xlab('Base score (mean)')
  ggsave(paste0(plot_dir, 'histogram.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'histogram.pdf'), units = 'in', width = 8, height = 6)
  
  ggplot(df_summary, aes(y = base_score_mean)) + 
    geom_flat_violin(mapping=aes(x=1), scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
    #geom_histogram(position = position_nudge(x = .2, y = 0)) +
    geom_point(mapping=aes(x=1), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
    geom_boxplot(mapping=aes(x=1), width = .1, outlier.shape = NA, alpha = 0.5 ) +
    theme(legend.position = 'none') + 
    coord_flip()
  ggsave(paste0(plot_dir, 'raincloud.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'raincloud.pdf'), units = 'in', width = 8, height = 6)
}

# Create image generation script to plot all paths
image_gen_script_filename = '../generate_images.sh'
if(!file.exists(image_gen_script_filename)){
  # Fetch map prefix
  map_0 = list.files('../shared_files/maps/')[1]
  map_prefix = strsplit(map_0, '0')[[1]][1]
  
  image_output_dir = 'images/'
  image_output_dir_from_here = paste0('../', image_output_dir)
  if(!dir.exists(image_output_dir_from_here)){
    cat('Plot directory does not exist. Creating: ', image_output_dir_from_here, '\n')
    dir.create(image_output_dir_from_here)
  }
  output_str = ''
  output_str = paste0(output_str, '#!/bin/bash\n\n')
  for(seed in unique(df$seed)){
    cat(seed, ' ')
    for(map_idx in unique(df$map_idx)){
      row = df[df$seed == seed & df$map_idx == map_idx,][1,]
      output_str = paste0(output_str, 'python3 ../../MABE2_extras/scripts/visualization/eval_patch_harvest.py')
      output_str = paste0(output_str, ' shared_files/maps/', map_prefix, map_idx, '.txt')
      output_str = paste0(output_str, ' ', row$movements)
      output_str = paste0(output_str, ' ', image_output_dir, 'seed_', seed, '__map_', map_idx, '.png\n')
    }
  }
  write(output_str, image_gen_script_filename)
  cat('\n')
}

# Create bash script to play any seed on any map 
replay_script_filename = '../replay.sh'
if(!file.exists(replay_script_filename)){
  # Fetch map prefix
  map_0 = list.files('../shared_files/maps/')[1]
  map_prefix = strsplit(map_0, '0')[[1]][1]
  
  output_str = ''
  output_str = paste0(output_str, '#!/bin/bash\n\n')
  output_str = paste0(output_str, 'if [ ! "$#" -eq 2 ]\n')
  output_str = paste0(output_str, 'then\n')
  output_str = paste0(output_str, '  echo "Two arguments required: the seed and map you wish to run"\n')
  output_str = paste0(output_str, '  exit 1\n')
  output_str = paste0(output_str, 'fi\n\n')
  
  for(seed in unique(df$seed)){
    cat(seed, ' ')
    output_str = paste0(output_str, '  if [ "$1" -eq ', seed,' ]\n')
    output_str = paste0(output_str, '  then\n')
    for(map_idx in unique(df$map_idx)){
      row = df[df$seed == seed & df$map_idx == map_idx,][1,]
      output_str = paste0(output_str, '    if [ "$2" -eq ', map_idx,' ]\n')
      output_str = paste0(output_str, '    then\n')
      output_str = paste0(output_str, '      python3 ../../MABE2_extras/scripts/visualization/eval_patch_harvest.py')
      output_str = paste0(output_str, ' shared_files/maps/', map_prefix, map_idx, '.txt')
      output_str = paste0(output_str, ' ', row$movements, '\n')
      output_str = paste0(output_str, '    fi\n')
    }
    output_str = paste0(output_str, '  fi\n')
  }
  write(output_str, replay_script_filename)
  cat('\n')
}

category_filename = paste0(data_dir, '/seed_categories.csv')
if(file.exists(category_filename)){
  df_category = read.csv(category_filename)
} else {
  df_category = data.frame(data = matrix(nrow = 0, ncol = 2))
  for(seed in unique(df$seed)){
    df_seed = df[df$seed == seed,]  
    if(length(unique(df_seed$movements)) == 1){
      df_category[nrow(df_category) + 1,] = c(seed, 'Set pattern')
    }
  }
  colnames(df_category) = c('seed', 'category')
  df_category$seed = as.numeric(df_category$seed)
  write.csv(df_category, paste0(data_dir, '/seed_categories.csv'), row.names = F)
}

# Find the top N seeds
num_seeds = nrow(df_summary)
top_seeds = 10 
cutoff_val = sort(df_summary$merit_mean)[(num_seeds-top_seeds + 1)]
df_top = df_summary[df_summary$merit_mean >= cutoff_val,]
cat('Here are the top ', top_seeds, ' seeds:\n')
print(df_top[order(df_top$merit_mean, decreasing = T),])

