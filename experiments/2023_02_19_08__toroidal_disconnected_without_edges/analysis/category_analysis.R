rm(list = ls())
source('./shared_config.R')

df = read.csv(paste0(processed_data_dir, '/processed_full.csv'))
df_summary = read.csv(paste0(processed_data_dir, '/processed_summary.csv'))
df_category = read.csv('../data/seed_categories.csv')

df$seed = as.numeric(df$seed)

df$category = NA
df_summary$category = NA
for(seed in unique(df$seed)){
  if(! seed %in% unique(df_category$seed)){
    cat('Missing category for seed: ', seed, '\n')
    next
  }
  category = df_category[df_category$seed == seed,]$category
  seed_mask = df$seed == seed
  df[seed_mask,]$category == category
  seed_mask_summary = df_summary$seed == seed
  df_summary[seed_mask_summary,]$category = category
}

df_category_counts = df_summary %>% dplyr::group_by(category) %>% dplyr::summarize(count = dplyr::n())

ggplot(df_summary, aes(x = as.factor(category), y = merit_mean, fill = as.factor(category))) + 
  geom_boxplot() + 
  scale_y_continuous(trans = 'log2') +
  scale_fill_manual(values = category_color_map)
ggsave(paste0(plot_dir, '/category_boxplots.png'), units = 'in', width = 8, height = 6)

ggplot(df_category_counts, aes(x = as.factor(category), y = count, fill = as.factor(category))) + 
  geom_col() + 
  scale_fill_manual(values = category_color_map)
ggsave(paste0(plot_dir, '/category_counts.png'), units = 'in', width = 8, height = 6)

ggplot(df_summary, aes(x = merit_mean, fill = as.factor(category))) + 
  geom_histogram() +
  scale_x_continuous(trans = 'log2') + 
  scale_fill_manual(values = category_color_map) +
  facet_grid(rows = vars(as.factor(category)))
ggsave(paste0(plot_dir, '/category_histrograms.png'), units = 'in', width = 8, height = 6)

ggplot(df_summary, aes(x = base_score_mean, fill = as.factor(category))) + 
  geom_histogram() +
  scale_x_continuous(trans = 'log2') + 
  scale_fill_manual(values = category_color_map) +
  facet_grid(rows = vars(as.factor(category)))

