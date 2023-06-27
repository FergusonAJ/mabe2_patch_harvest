rm(list = ls())

source('./shared_config.R')

# Load data
df_summary = load_final_dom_categorized_summary()

# Summarize by category
df_category_counts = df_summary %>% dplyr::group_by(category) %>% dplyr::summarize(count = dplyr::n())

ggplot(df_summary, aes(x = as.factor(category), y = merit_mean, fill = as.factor(category))) + 
  geom_boxplot() + 
  scale_y_continuous(trans = 'log2') +
  scale_fill_manual(values = category_color_map)
ggsave(paste0(plot_dir, '/final_dom__category_boxplots.png'), units = 'in', width = 8, height = 6)

ggplot(df_category_counts, aes(x = as.factor(category), y = count, fill = as.factor(category))) + 
  geom_col() + 
  scale_fill_manual(values = category_color_map)
ggsave(paste0(plot_dir, '/final_dom__category_counts.png'), units = 'in', width = 8, height = 6)

ggplot(df_summary, aes(x = merit_mean, fill = as.factor(category))) + 
  geom_histogram() +
  scale_x_continuous(trans = 'log2') + 
  scale_fill_manual(values = category_color_map) +
  facet_grid(rows = vars(as.factor(category)))
ggsave(paste0(plot_dir, '/final_dom__category_merit_histograms.png'), units = 'in', width = 8, height = 6)

ggplot(df_summary, aes(x = base_score_mean, fill = as.factor(category))) + 
  geom_histogram() +
  scale_fill_manual(values = category_color_map) +
  facet_grid(rows = vars(as.factor(category)))
ggsave(paste0(plot_dir, '/final_dom__category_score_histograms.png'), units = 'in', width = 8, height = 6)
