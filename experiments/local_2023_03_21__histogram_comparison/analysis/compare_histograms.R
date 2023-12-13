rm(list = ls())

library(ggplot2)
library(dplyr)

df = NA

dir_list = list.dirs('../../', recursive = F)
dir_list = dir_list[c(grep('2023_02_19', dir_list), grep('2023_02_20', dir_list))]

font_size_large = 16
font_size_small = 14
bin_width = 0.02

env_map = c(
'toroidal_rect' = 'Rectangular',
'toroidal_rect_no_edge' = 'Rectangular', 
'toroidal_rect_with_hole_and_edges' = 'Rectangular', 
'toroidal_irregular_with_edges' = 'Irregular', 
'toroidal_irregular_with_hole_and_edges' = 'Irregular', 
'toroidal_connected_patches' = 'Connected Patches', 
'toroidal_disconnected_with_edges' = 'Disconnected Patches', 
'toroidal_disconnected_without_edges' = 'Disconnected Patches', 
'new_env_rect_with_hole_without_edges' = 'Rectangular', 
'new_env_connected_patches_without_edges' = 'Connected Patches', 
'irregular_without_edges' = 'Irregular', 
'irregular_with_holes_without_edges' = 'Irregular' 
)
edge_map = c(
'toroidal_rect' = T,
'toroidal_rect_no_edge' = F, 
'toroidal_rect_with_hole_and_edges' = T, 
'toroidal_irregular_with_edges' = T, 
'toroidal_irregular_with_hole_and_edges' = T, 
'toroidal_connected_patches' = T, 
'toroidal_disconnected_with_edges' = T, 
'toroidal_disconnected_without_edges' = F, 
'new_env_rect_with_hole_without_edges' = F, 
'new_env_connected_patches_without_edges' = F, 
'irregular_without_edges' = F, 
'irregular_with_holes_without_edges' = F 
)
hole_map = c(
'toroidal_rect' = F,
'toroidal_rect_no_edge' = F, 
'toroidal_rect_with_hole_and_edges' = T, 
'toroidal_irregular_with_edges' = F, 
'toroidal_irregular_with_hole_and_edges' = T, 
'toroidal_connected_patches' = F, 
'toroidal_disconnected_with_edges' = F, 
'toroidal_disconnected_without_edges' = F, 
'new_env_rect_with_hole_without_edges' = T, 
'new_env_connected_patches_without_edges' = F, 
'irregular_without_edges' = F, 
'irregular_with_holes_without_edges' = T 
)

for(dir_name in dir_list){
  exp_name = substr(dir_name, regexpr('__', dir_name)[1] + 2, nchar(dir_name))
  cat(exp_name, '\n')
  processed_summary_filename = paste0(dir_name, '/data/processed/processed_summary.csv')
  df_tmp = read.csv(processed_summary_filename)
  df_tmp$exp_name = exp_name
  df_tmp$env_name = env_map[exp_name]
  df_tmp$has_edges = edge_map[exp_name]
  df_tmp$has_hole = hole_map[exp_name]
  
  df_tmp$category = NA
  category_filename = paste0(dir_name, '/data/seed_categories.csv')
  if(file.exists(category_filename)){
    df_tmp_category = read.csv(category_filename)
    for(seed in unique(df_tmp$seed)){
      if(! seed %in% unique(df_tmp_category$seed)){
        cat('Missing category for seed: ', seed, '\n')
        next
      }
      category = df_tmp_category[df_tmp_category$seed == seed,]$category
      seed_mask = df_tmp$seed == seed
      df_tmp[seed_mask,]$category = category
    }
  }
  
  if(!is.data.frame(df)){
    df = df_tmp
  } else {
    df = rbind(df, df_tmp)
  }
}

ggplot(df, aes(x = base_score_mean)) + 
  geom_histogram() + 
  facet_wrap(vars(exp_name))

df$modifier = 'Edges and no hole'
df[df$has_edges == F & df$has_hole == F,]$modifier = 'No edges or hole'
df[df$has_edges == T & df$has_hole == T,]$modifier = 'Edges and hole'
df[df$has_edges == F & df$has_hole == T,]$modifier = 'Hole and no edges'

df$env_factor = factor(df$env_name, levels = c('Rectangular', 'Irregular', 'Disconnected Patches', 'Connected Patches'))
df$modifier_factor = factor(df$modifier, levels = c('Edges and no hole', 'No edges or hole', 'Edges and hole', 'Hole and no edges'))


df_summary = df %>% dplyr::group_by(env_factor, modifier_factor) %>% dplyr::summarize(
  merit_grand_mean = mean(merit_mean),
  task_quality_grand_mean = mean(task_quality_mean),
  coverage_grand_mean = mean(coverage_mean)
)


ggplot(df, aes(x = base_score_mean)) + 
  geom_histogram(binwidth = 30) + 
  xlab('Mean score') +
  ylab('Count') +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))

ggplot(df, aes(x = merit_mean)) + 
  geom_histogram(binwidth = 10) + 
  xlab('Mean merit') +
  ylab('Count') +
  scale_x_continuous(trans = 'log2') +
  theme(axis.title = element_text(size = font_size_large)) +
  theme(axis.text = element_text(size = font_size_small)) +
  theme(axis.text.x = element_text(size = font_size_small, angle = 90)) +
  theme(strip.text = element_text(size = font_size_small)) +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/histograms_merit.png', units = 'in', width = 12, height = 10)

ggplot(df, aes(x = base_score_median)) + 
  geom_histogram(binwidth = 30) + 
  xlab('Median score') +
  ylab('Count') +
  theme(axis.title = element_text(size = font_size_large)) +
  theme(axis.text = element_text(size = font_size_small)) +
  theme(strip.text = element_text(size = font_size_small)) +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/histograms_score.png', units = 'in', width = 12, height = 8)

ggplot(df, aes(x = task_quality_mean)) + 
  geom_vline(data = df_summary, aes(xintercept=task_quality_grand_mean), linetype = 'dashed') +
  geom_text(data = df_summary, aes(x=task_quality_grand_mean + 0.1, y = 50, label = round(task_quality_grand_mean, 2)), linetype = 'dashed') +
  geom_histogram(binwidth = bin_width) + 
  xlab('Average task quality') +
  ylab('Count') +
  scale_x_continuous(limits = c(0,1)) +
  theme(axis.title = element_text(size = font_size_large)) +
  theme(axis.text = element_text(size = font_size_small)) +
  theme(strip.text = element_text(size = font_size_small)) +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/histograms_average_task_quality.png', units = 'in', width = 12, height = 8)

ggplot(df, aes(x = task_quality_median)) + 
  geom_histogram(binwidth = bin_width) + 
  xlab('Median task quality') +
  ylab('Count') +
  scale_x_continuous(limits = c(0,1)) +
  theme(axis.title = element_text(size = font_size_large)) +
  theme(axis.text = element_text(size = font_size_small)) +
  theme(strip.text = element_text(size = font_size_small)) +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/histograms_median_task_quality.png', units = 'in', width = 12, height = 8)

ggplot(df, aes(x = task_quality_max)) + 
  geom_histogram(binwidth = bin_width) + 
  xlab('Maximum task quality') +
  ylab('Count') +
  scale_x_continuous(limits = c(0,1)) +
  theme(axis.title = element_text(size = font_size_large)) +
  theme(axis.text = element_text(size = font_size_small)) +
  theme(strip.text = element_text(size = font_size_small)) +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/histograms_max_task_quality.png', units = 'in', width = 12, height = 8)

ggplot(df, aes(x = coverage_mean)) + 
  geom_vline(data = df_summary, aes(xintercept=coverage_grand_mean), linetype = 'dashed') +
  geom_text(data = df_summary, aes(x=coverage_grand_mean + 0.1, y = 50, label = round(coverage_grand_mean, 2)), linetype = 'dashed') +
  geom_histogram(binwidth = bin_width) + 
  xlab('Average coverage') +
  ylab('Count') +
  scale_x_continuous(limits = c(0,1)) +
  theme(axis.title = element_text(size = font_size_large)) +
  theme(axis.text = element_text(size = font_size_small)) +
  theme(strip.text = element_text(size = font_size_small)) +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/histograms_average_coverage.png', units = 'in', width = 12, height = 8)

ggplot(df, aes(x = coverage_median)) + 
  geom_histogram(binwidth = bin_width) + 
  xlab('Median coverage') +
  ylab('Count') +
  scale_x_continuous(limits = c(0,1)) +
  theme(axis.title = element_text(size = font_size_large)) +
  theme(axis.text = element_text(size = font_size_small)) +
  theme(strip.text = element_text(size = font_size_small)) +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/histograms_median_coverage.png', units = 'in', width = 12, height = 8)

ggplot(df, aes(x = coverage_max)) + 
  geom_histogram(binwidth = bin_width) + 
  xlab('Maximum coverage') +
  ylab('Count') +
  scale_x_continuous(limits = c(0,1)) +
  theme(axis.title = element_text(size = font_size_large)) +
  theme(axis.text = element_text(size = font_size_small)) +
  theme(strip.text = element_text(size = font_size_small)) +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/histograms_max_coverage.png', units = 'in', width = 12, height = 8)


ggplot(df, aes(x = task_quality_mean, y = task_quality_median)) + 
  geom_abline(aes(intercept = 0, slope = 1)) +
  geom_point() +#histogram(binwidth = 0.05) + 
  scale_x_continuous(limits = c(0,1))
  #xlab('Average task quality') +
  #ylab('Count')

#df_summary = df %>% dplyr::group_by(exp_name) %>% dplyr::summarize(mean_mean_task_quality = mean(task_quality_mean), mean_max_task_quality = mean(task_quality_max), mean_mean_covereage = mean(coverage_mean))

category_color_map = c(
  'Spiraling' = '#4477AA', 
  'Plowing' = '#EE6677', 
  'Reactive meandering' = '#CCBB44', 
  'Pattern cycling' = '#228833', 
  'Set pattern' = '#AA3377', 
  'Loop' ='#66CCEE' ,
  'None' = '#BBBBBB'
)
df_category_counts = df %>% dplyr::group_by(exp_name, category, modifier_factor, env_factor) %>% dplyr::summarize(count = dplyr::n(),
                                                                                                                  task_quality_mean_min = min(task_quality_mean),
                                                                                                                  task_quality_mean_max = max(task_quality_mean),
                                                                                                                  task_quality_median_min = min(task_quality_median),
                                                                                                                  task_quality_median_max = max(task_quality_median))

df_just_category_counts = df %>% dplyr::group_by(category) %>% dplyr::summarize(count = dplyr::n(),
                                                                                task_quality_mean_min = min(task_quality_mean),
                                                                                task_quality_mean_max = max(task_quality_mean),
                                                                                task_quality_median_min = min(task_quality_median),
                                                                                task_quality_median_max = max(task_quality_median))


ggplot(df_category_counts, aes(x = as.factor(category), y = count, fill = as.factor(category))) + 
  geom_col() + 
  geom_text(aes(y = count + 10, label = count)) +
  scale_fill_manual(values = category_color_map) + 
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/category_counts.png', units = 'in', width = 12, height = 8)

ggplot(df_category_counts, aes(x = as.factor(category), ymin = task_quality_mean_min, ymax = task_quality_mean_max, color = as.factor(category))) + 
  geom_errorbar() +
  scale_color_manual(values = category_color_map) + 
  scale_y_continuous(limits = 0:1) +
  theme(axis.text.x = element_blank()) +
  xlab('Category') +
  ylab('Task quality') +
  labs(color = 'Category') +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor)) 
ggsave('../plots/category_ranges_mean.png', units = 'in', width = 12, height = 8)

ggplot(df_category_counts, aes(x = as.factor(category), ymin = task_quality_median_min, ymax = task_quality_median_max, color = as.factor(category))) + 
  geom_errorbar() +
  scale_color_manual(values = category_color_map) + 
  scale_y_continuous(limits = 0:1) +
  theme(axis.text.x = element_blank()) +
  xlab('Category') +
  ylab('Task quality') +
  labs(color = 'Category') +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor)) 
ggsave('../plots/category_ranges_median.png', units = 'in', width = 12, height = 8)

write.csv(df_category_counts, '../data/processed_categories.csv')


ggplot(df_just_category_counts, aes(x = as.factor(category), ymin = task_quality_mean_min, ymax = task_quality_mean_max, color = as.factor(category))) + 
  geom_errorbar() +
  scale_color_manual(values = category_color_map) + 
  scale_y_continuous(limits = 0:1) +
  theme(axis.text.x = element_blank()) +
  xlab('Category') +
  ylab('Task quality') +
  labs(color = 'Category')
ggsave('../plots/just_category_mean_ranges.png', units = 'in', width = 8, height = 6)

ggplot(df_just_category_counts, aes(x = as.factor(category), ymin = task_quality_median_min, ymax = task_quality_median_max, color = as.factor(category))) + 
  geom_errorbar() +
  scale_color_manual(values = category_color_map) + 
  scale_y_continuous(limits = 0:1) +
  theme(axis.text.x = element_blank()) +
  xlab('Category') +
  ylab('Task quality') +
  labs(color = 'Category')
ggsave('../plots/just_category_median_ranges.png', units = 'in', width = 8, height = 6)

write.csv(df_just_category_counts, '../data/processed_just_categories.csv')

ggplot(df, aes(x = task_quality_mean)) + 
  geom_vline(data = df_summary, aes(xintercept=task_quality_grand_mean), linetype = 'dashed') +
  geom_text(data = df_summary, aes(x=task_quality_grand_mean + 0.1, y = 50, label = round(task_quality_grand_mean, 2)), linetype = 'dashed') +
  geom_histogram(aes(fill = as.factor(category)), binwidth = bin_width) + 
  xlab('Average task quality') +
  ylab('Count') +
  scale_x_continuous(limits = c(0,1)) +
  scale_fill_manual(values = category_color_map) + 
  theme(axis.title = element_text(size = font_size_large)) +
  theme(axis.text = element_text(size = font_size_small)) +
  theme(strip.text = element_text(size = font_size_small)) +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/histograms_average_task_quality__categorized.png', units = 'in', width = 12, height = 8)

ggplot(df, aes(x = task_quality_max)) + 
  geom_histogram(aes(fill = as.factor(category)), binwidth = bin_width) + 
  xlab('Maximum task quality') +
  ylab('Count') +
  scale_x_continuous(limits = c(0,1)) +
  scale_fill_manual(values = category_color_map) + 
  theme(axis.title = element_text(size = font_size_large)) +
  theme(axis.text = element_text(size = font_size_small)) +
  theme(strip.text = element_text(size = font_size_small)) +
  facet_grid(rows = vars(modifier_factor), cols = vars(env_factor))
ggsave('../plots/histograms_max_task_quality__categorized.png', units = 'in', width = 12, height = 8)

ggplot(df, aes(x = modifier_factor, y = task_quality_mean, fill = as.factor(modifier_factor))) + 
  geom_boxplot() + 
  ylab('Average task quality') +
  labs(fill = 'Treatment') +
  scale_y_continuous(limits = c(0,1)) +
  facet_grid(rows = vars(env_factor)) + 
  theme(axis.text.x = element_blank()) +
  theme(axis.title.x = element_blank())+
  theme(axis.ticks.x = element_blank())
ggsave('../plots/treatment_boxplots_per_environment.png', units = 'in', width = 5, height = 12)
  
df_stats = data.frame(data = matrix(nrow = 0, ncol = 7))
colnames(df_stats) = c('env', 'kruskal_p_value', 'hole_mann_whitney', 'no_hole_mann_whitney', 'adjusted_kruskal', 'adjusted_hole', 'adjusted_no_hole')
for(env_factor in unique(df$env_factor)){
  cat('Env: ', env_factor, '\n')
  df_stats[nrow(df_stats) + 1,] = c(env_factor, NA, NA, NA, NA, NA, NA)
  df_env = df[df$env_factor == env_factor,]  
  kruskal_results = kruskal.test(task_quality_mean ~ modifier_factor, data = df_env)
  kruskal_p_value = kruskal_results[['p.value']]
  df_stats[df_stats$env == env_factor,]$kruskal_p_value = kruskal_p_value
  cat('  Kruskal-Wallis p-value: ', kruskal_p_value, '\n')
  env_modifiers = unique(df_env$modifier_factor)
  if(kruskal_p_value >= 0.05){
    cat('  No difference detected with Kruskal-Wallis. Continuing to next environment\n')
    next
  }
  p_values = c(kruskal_p_value)
  p_value_labels = c('adjusted_kruskal')
  if('Edges and no hole' %in% env_modifiers & 'No edges or hole' %in% env_modifiers){
    df_mod = df_env[df_env$modifier %in% c('Edges and no hole', 'No edges or hole'),]
    no_hole_wilcox_result = wilcox.test(df_mod$task_quality_mean ~ df_mod$modifier_factor)
    no_hole_wilcox_p_value = no_hole_wilcox_result[['p.value']]
    df_stats[df_stats$env == env_factor,]$no_hole_mann_whitney = no_hole_wilcox_p_value
    cat('  No hole Mann-Whitney: ', no_hole_wilcox_p_value, '\n')
    p_values = c(p_values, no_hole_wilcox_p_value)
    p_value_labels = c(p_value_labels, c('adjusted_no_hole'))
  }
  if('Edges and hole' %in% env_modifiers & 'Hole and no edges' %in% env_modifiers){
    df_mod = df_env[df_env$modifier %in% c('Edges and hole', 'Hole and no edges'),]
    hole_wilcox_result = wilcox.test(df_mod$task_quality_mean ~ df_mod$modifier_factor)
    hole_wilcox_p_value = hole_wilcox_result[['p.value']]
    df_stats[df_stats$env == env_factor,]$hole_mann_whitney = hole_wilcox_p_value
    cat('  Hole Mann-Whitney: ', hole_wilcox_p_value, '\n')
    p_values = c(p_values, hole_wilcox_p_value)
    p_value_labels = c(p_value_labels, c('adjusted_hole'))
  }
  adj_p_values = p.adjust(p_values, method = 'holm')
  for(i in 1:length(p_values)){
    adj_p_value = adj_p_values[i]
    label = p_value_labels[i]
    cat('  ', label, ' ', adj_p_value, '\n')
    df_stats[df_stats$env == env_factor,label] = adj_p_value
  }
}
data_dir = '../data'
if(!dir.exists(data_dir)){
  dir.create(data_dir)
}
df_stats_filename = paste0(data_dir, '/stats.csv')
write.csv(df_stats, df_stats_filename)
cat('Stats written to: ', df_stats_filename)

for(env_factor in unique(df$env_factor)){
  df_env = df[df$env_factor == env_factor,]
  for(modifier_factor in unique(df_env$modifier_factor)){
    df_mod = df_env[df_env$modifier_factor == modifier_factor,]
    for(category in unique(df_mod$category)){
      df_tmp = df_mod[df_mod$category == category,]
      cat(env_factor, ' ', modifier_factor, ' ', category, ' -> ', nrow(df_tmp), '\n')
    }
  }
}
df_env_category_summary = dplyr::group_by(df, env_factor, modifier_factor, category) %>%
                          dplyr::summarize(count = dplyr::n())
