rm(list = ls())

source('./shared_config.R')

df = load_final_dom_processed_data()
df_summary = load_final_dom_processed_summary()
df_map_summary = load_final_dom_processed_map_summary()

# Raw data, one boxplot per seed, ordered
ggplot(df, aes(x = as.factor(seed_order), y = merit + 0.01)) + 
  geom_boxplot() + 
  scale_y_continuous(trans='log2') + 
  theme(axis.text.x = element_blank()) + 
  theme(axis.ticks.x = element_blank()) + 
  ylab('Merit (log2 scale with zeros shown)') + 
  xlab('Seed (ordered by median merit)')
ggsave(paste0(plot_dir, '/final_dom__merit_boxplots.png'), units = 'in', width = 8, height = 6)
#ggsave(paste0(plot_dir, '/final_dom__merit_boxplots.pdf'), units = 'in', width = 8, height = 6)

ggplot(df_summary, aes(x = merit_median, y = merit_mean)) + 
  geom_point() +
  geom_abline(aes(slope=1, intercept=0)) +
  scale_y_continuous(trans='log2') +
  scale_x_continuous(trans='log2') +
  xlab('Median merit (log2 scale)') +
  ylab('Mean merit (log2 scale)')
ggsave(paste0(plot_dir, '/final_dom__merit_median_vs_mean.png'), units = 'in', width = 8, height = 6)
#ggsave(paste0(plot_dir, '/final_dom__merit_median_vs_mean.pdf'), units = 'in', width = 8, height = 6)


## Data summarized by map
#ggplot(df_map_summary, aes(x = as.factor(seed_order), y = merit_mean + 0.1)) + 
#  geom_boxplot() +
#  scale_y_continuous(trans='log2') + 
#  theme(axis.text.x = element_blank()) + 
#  theme(axis.ticks.x = element_blank()) + 
#  ylab('Merit of each map (log2 scale with zeros shown)') + 
#  xlab('Seed (ordered by median merit)') 
#ggsave(paste0(plot_dir, '/final_dom__map__median_merit.png'), units = 'in', width = 8, height = 6)
#ggsave(paste0(plot_dir, '/final_dom__map__median_merit.pdf'), units = 'in', width = 8, height = 6)
#
#ggplot(df_map_summary, aes(x = as.factor(seed_order), y = merit_sd)) + 
#  geom_point() +
#  theme(axis.text.x = element_blank()) + 
#  theme(axis.ticks.x = element_blank()) + 
#  ylab('Standard variation of merit for each map') + 
#  xlab('Seed (ordered by median merit)') 
#ggsave(paste0(plot_dir, '/final_dom__map__sd_merit.png'), units = 'in', width = 8, height = 6)
#ggsave(paste0(plot_dir, '/final_dom__map__sd_merit.pdf'), units = 'in', width = 8, height = 6)


# Plot data distribution to identify potential groups
ggplot(df_summary, aes(x = base_score_mean)) + 
  geom_histogram(binwidth = 25) + 
  geom_jitter(mapping = aes(y = -3), position = position_jitter(height = 2, seed = 10), alpha = 0.2) +
  ylab('Frequency') + 
  xlab('Base score (mean)')
ggsave(paste0(plot_dir, '/final_dom__merit_mean_histogram.png'), units = 'in', width = 8, height = 6)
#ggsave(paste0(plot_dir, '/final_dom__merit_mean_histogram.pdf'), units = 'in', width = 8, height = 6)

ggplot(df_summary, aes(y = base_score_mean)) + 
  geom_flat_violin(mapping=aes(x=1), scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
  #geom_histogram(position = position_nudge(x = .2, y = 0)) +
  geom_point(mapping=aes(x=1), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
  geom_boxplot(mapping=aes(x=1), width = .1, outlier.shape = NA, alpha = 0.5 ) +
  theme(legend.position = 'none') + 
  coord_flip()
ggsave(paste0(plot_dir, '/final_dom__merit_mean_raincloud.png'), units = 'in', width = 8, height = 6)
#ggsave(paste0(plot_dir, '/final_dom__merit_mean_raincloud.pdf'), units = 'in', width = 8, height = 6)
