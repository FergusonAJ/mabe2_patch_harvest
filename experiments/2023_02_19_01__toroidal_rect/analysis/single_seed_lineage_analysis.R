rm(list = ls())

source('./shared_config.R')

seed = 31
plot_dir = paste0(plot_dir, 'reps/',seed,'/')
if(!dir.exists(plot_dir)){
  dir.create(plot_dir, recursive = T)
}
scripts_dir = paste0('../scripts/reps/')
if(!dir.existis(scripts_dir)){
  dir.create(scripts_dir, recursive = T)
}
rep_scripts_dir = paste0(scripts_dir, seed, '/')
if(!dir.exists(rep_scripts_dir)){
  dir.create(rep_scripts_dir, recursive = T)
}
rep_data_dir = paste0(data_dir, '/reps/', seed)

# Load the data
filename = paste0(rep_data_dir, '/dominant_lineage_summary.csv')
if(!file.exists(filename)){
  cat('Error! Data file does not exist: ', filename)
  cat(' Exiting!\n')
  quit()
}
df = read.csv(filename)
df = df[!is.na(df$map_idx),]
df$nutrients_consumed = df$nutrients_consumed_mean
df$moves_off_path = df$moves_off_path_mean
df$base_score = df$nutrients_consumed - df$moves_off_path
df$total_nutrients = round(130 * df$base_score / log(df$merit, base = 2))
# Extract total nutrients assuming *some* replicates had a positive score
for(map_idx in unique(df$map_idx)){
  map_mask = df$map_idx == map_idx
  total_nutrients = max(df[map_mask,]$total_nutrients, na.rm = T)
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

# Plot!
if(T){
  ggplot(df_summary, aes(x = base_score_mean)) + 
    geom_histogram(binwidth = 25) + 
    geom_jitter(mapping = aes(y = -3), position = position_jitter(height = 2, seed = 10), alpha = 0.2) +
    ylab('Frequency') + 
    xlab('Base score (mean)')
  ggsave(paste0(plot_dir, 'lineage_score_histogram.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'lineage_score_histogram.pdf'), units = 'in', width = 8, height = 6)
  
  ggplot(df_summary, aes(y = base_score_mean)) + 
    geom_flat_violin(mapping=aes(x=1), scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
    #geom_histogram(position = position_nudge(x = .2, y = 0)) +
    geom_point(mapping=aes(x=1), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
    geom_boxplot(mapping=aes(x=1), width = .1, outlier.shape = NA, alpha = 0.5 ) +
    theme(legend.position = 'none') + 
    coord_flip()
  ggsave(paste0(plot_dir, 'lineage_score_raincloud.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'lineage_score_raincloud.pdf'), units = 'in', width = 8, height = 6)
  
  ggplot(df_summary, aes(x = depth, y = task_quality_mean)) + 
    geom_point(size = 0.5)
  ggsave(paste0(plot_dir, 'lineage_task_quality_mean.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'lineage_task_quality_mean.pdf'), units = 'in', width = 8, height = 6)
    #geom_point(aes(y = task_quality_max), size = 0.5, color = 'red') +
    #geom_point(aes(y = task_quality_min), size = 0.5, color = 'blue')
}

# Create image generation script to plot all paths
image_gen_script_filename = paste0(rep_scripts_dir, 'generate_images_', seed, '.sh')
if(!file.exists(image_gen_script_filename)){
  # Fetch map prefix
  map_0 = list.files('../shared_files/maps/')[1]
  map_prefix = strsplit(map_0, '0')[[1]][1]
  
  image_output_dir = paste0('images/reps/', seed, '/')
  image_output_dir_from_here = paste0('../', image_output_dir)
  if(!dir.exists(image_output_dir_from_here)){
    cat('Plot directory does not exist. Creating: ', image_output_dir_from_here, '\n')
    dir.create(image_output_dir_from_here, recursive = T)
  }

  output_str = ''
  output_str = paste0(output_str, '#!/bin/bash\n\n')
  for(depth in unique(df$depth)){
    cat(depth, ' ')
    for(map_idx in unique(df$map_idx)){
      row = df[df$depth == depth & df$map_idx == map_idx,][1,]
      output_str = paste0(output_str, 'python3 ../../MABE2_extras/scripts/visualization/eval_patch_harvest.py')
      output_str = paste0(output_str, ' shared_files/maps/', map_prefix, map_idx, '.txt')
      output_str = paste0(output_str, ' ', row$movements)
      output_str = paste0(output_str, ' ', image_output_dir, 'depth_', depth, '__map_', map_idx, '.png\n') # gif_tmp\n')
    }
  }
  write(output_str, image_gen_script_filename)
  system(paste0('chmod u+x ', image_gen_script_filename))
  cat('\n')
}

# Create bash script to play any depth on any map 
replay_script_filename = paste0(rep_scripts_dir, 'replay_', seed, '.sh')
if(!file.exists(replay_script_filename)){
  # Fetch map prefix
  map_0 = list.files('../shared_files/maps/')[1]
  map_prefix = strsplit(map_0, '0')[[1]][1]
  
  output_str = ''
  output_str = paste0(output_str, '#!/bin/bash\n\n')
  output_str = paste0(output_str, 'if [ ! "$#" -eq 2 ]\n')
  output_str = paste0(output_str, 'then\n')
  output_str = paste0(output_str, '  echo "Two arguments required: the depth and map you wish to run"\n')
  output_str = paste0(output_str, '  exit 1\n')
  output_str = paste0(output_str, 'fi\n\n')
  
  for(depth in unique(df$depth)){
    cat(depth, ' ')
    output_str = paste0(output_str, '  if [ "$1" -eq ', depth,' ]\n')
    output_str = paste0(output_str, '  then\n')
    for(map_idx in unique(df$map_idx)){
      row = df[df$depth == depth & df$map_idx == map_idx,][1,]
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
  system(paste0('chmod u+x ', replay_script_filename))
  cat('\n')
}

category_filename = paste0(rep_data_dir, '/depth_categories.csv')
if(file.exists(category_filename)){
  df_category = read.csv(category_filename)
} else {
  df_category = data.frame(data = matrix(nrow = 0, ncol = 2))
  for(depth in unique(df$depth)){
    df_depth = df[df$depth == depth,]  
    if(length(unique(df_depth$movements)) == 1){
      df_category[nrow(df_category) + 1,] = c(depth, 'Set pattern')
    }
  }
  colnames(df_category) = c('depth', 'category')
  df_category$depth = as.numeric(df_category$depth)
  write.csv(df_category, paste0(rep_data_dir, '/depth_categories.csv'), row.names = F)
}

# Find the top N depths
num_depths = nrow(df_summary)
top_depths = 10 
cutoff_val = sort(df_summary$merit_mean)[(num_depths-top_depths + 1)]
df_top = df_summary[df_summary$merit_mean >= cutoff_val,]
cat('Here are the top ', top_depths, ' depths:\n')
print(df_top[order(df_top$merit_mean, decreasing = T),])


notable_depth_step = 50
notable_depths = seq(0, max(df$depth), notable_depth_step)
notable_depths = c(notable_depths, max(df$depth))
for(depth in 1:max(df$depth)){
  task_quality_diff = df_summary[df_summary$depth == depth,]$task_quality_mean - df_summary[df_summary$depth == (depth - 1),]$task_quality_mean
  if(abs(task_quality_diff) >= 0.001){
    notable_depths = c(notable_depths, depth)
  }
}
notable_depths = sort(unique(notable_depths))

df_summary$is_notable = F
df_summary[df_summary$depth %in% notable_depths,]$is_notable = T
ggplot(df_summary, aes(x = depth, y = task_quality_mean)) + 
  geom_point(size = 0.5) +
  geom_point(data=df_summary[df_summary$is_notable,], size = 0.5, color = 'red')
  ggsave(paste0(plot_dir, 'lineage_task_quality_mean_notable.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'lineage_task_quality_mean_notable.pdf'), units = 'in', width = 8, height = 6)

# Create image generation script for notable depths 
notable_gen_script_filename = paste0(rep_scripts_dir, 'generate_notable_images_', seed, '.sh')
if(!file.exists(notable_gen_script_filename)){
  # Fetch map prefix
  map_0 = list.files('../shared_files/maps/')[1]
  map_prefix = strsplit(map_0, '0')[[1]][1]
  
  image_output_dir = paste0('images/reps/', seed, '/')
  image_output_dir_from_here = paste0('../', image_output_dir)
  if(!dir.exists(image_output_dir_from_here)){
    cat('Plot directory does not exist. Creating: ', image_output_dir_from_here, '\n')
    dir.create(image_output_dir_from_here, recursive = T)
  }

  output_str = ''
  output_str = paste0(output_str, '#!/bin/bash\n\n')
  for(depth in notable_depths){
    cat(depth, ' ')
    for(map_idx in unique(df$map_idx)){
      row = df[df$depth == depth & df$map_idx == map_idx,][1,]
      output_str = paste0(output_str, 'python3 ../../MABE2_extras/scripts/visualization/eval_patch_harvest.py')
      output_str = paste0(output_str, ' shared_files/maps/', map_prefix, map_idx, '.txt')
      output_str = paste0(output_str, ' ', row$movements)
      output_str = paste0(output_str, ' ', image_output_dir, 'depth_', depth, '__map_', map_idx, '.png\n') # gif_tmp\n')
    }
  }
  write(output_str, notable_gen_script_filename)
  system(paste0('chmod u+x ', notable_gen_script_filename))
  cat('\n')
}

depth_category_filename = paste0('../data/seed_categories_rep_', seed, '.csv')
if(file.exists(depth_category_filename)) {
  df_category = read.csv(depth_category_filename)
  df_summary$category = NA
  for(depth in df_category$depth){
    df_summary[df_summary$depth == depth,]$category = df_category[df_category$depth == depth,]$category
  }
  ggplot(df_summary, aes(x = depth, y = task_quality_mean)) + 
    geom_point(size = 0.5) +
    geom_point(data=df_summary[!is.na(df_summary$category),], aes(color = as.factor(category)), size = 0.75) + 
    scale_color_manual(values = category_color_map)
  ggsave(paste0(plot_dir, 'lineage_task_quality_mean_categorized.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, 'lineage_task_quality_mean_categorized.pdf'), units = 'in', width = 8, height = 6)
}
