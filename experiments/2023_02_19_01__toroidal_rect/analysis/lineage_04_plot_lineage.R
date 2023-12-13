library(ggplot2)

source('shared_config_lineage.R')

lineage_func_04_plot_lineage = function(seed){
  # Load data
  df_summary = load_lineage_processed_summary(seed)
  
  rep_plot_dir = get_lineage_plot_dir(seed)
  
  # Plot!
  ggplot(df_summary, aes(x = base_score_mean)) + 
    geom_histogram(binwidth = 25) + 
    geom_jitter(mapping = aes(y = -3), position = position_jitter(height = 2, seed = 10), alpha = 0.2) +
    ylab('Frequency') + 
    xlab('Base score (mean)')
  ggsave(paste0(rep_plot_dir, '/lineage_score_histogram.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(rep_plot_dir, '/lineage_score_histogram.pdf'), units = 'in', width = 8, height = 6)
  
  ggplot(df_summary, aes(y = base_score_mean)) + 
    geom_flat_violin(mapping=aes(x=1), scale="width", position = position_nudge(x = .2, y = 0), alpha = .8 ) + 
    #geom_histogram(position = position_nudge(x = .2, y = 0)) +
    geom_point(mapping=aes(x=1), position = position_jitter(width = .15, height = 0), size = .5, alpha = 0.8 ) + 
    geom_boxplot(mapping=aes(x=1), width = .1, outlier.shape = NA, alpha = 0.5 ) +
    theme(legend.position = 'none') + 
    coord_flip()
  ggsave(paste0(rep_plot_dir, '/lineage_score_raincloud.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(rep_plot_dir, '/lineage_score_raincloud.pdf'), units = 'in', width = 8, height = 6)
  
  ggplot(df_summary, aes(x = depth, y = task_quality_mean)) + 
    geom_point(size = 0.5)
  ggsave(paste0(rep_plot_dir, '/lineage_task_quality_mean.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(rep_plot_dir, '/lineage_task_quality_mean.pdf'), units = 'in', width = 8, height = 6)
  
  ggplot(df_summary, aes(x = depth, y = task_quality_mean)) + 
    geom_point(size = 0.5) +
    geom_point(data=df_summary[df_summary$is_notable,], size = 0.5, color = 'red')
  ggsave(paste0(rep_plot_dir, '/lineage_task_quality_mean_notable.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(rep_plot_dir, '/lineage_task_quality_mean_notable.pdf'), units = 'in', width = 8, height = 6)
}
