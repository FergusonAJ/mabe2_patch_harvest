library(ggplot2)

source('shared_config_lineage.R')

lineage_func_07_plot_lineage_with_categories = function(seed){
  # Load data
  df_summary = load_lineage_processed_summary_with_categories(seed)
  
  rep_plot_dir = get_lineage_plot_dir(seed)
  
  ggplot(df_summary, aes(x = depth, y = task_quality_mean)) + 
    geom_point(size = 0.5) +
    geom_point(data=df_summary[!is.na(df_summary$category),], aes(color = as.factor(category)), size = 0.75) + 
    scale_color_manual(values = category_color_map)
  ggsave(paste0(rep_plot_dir, 'lineage_task_quality_mean_categorized.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(rep_plot_dir, 'lineage_task_quality_mean_categorized.pdf'), units = 'in', width = 8, height = 6)
}
