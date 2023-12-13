library(ggplot2)

source('shared_config_lineage.R')

lineage_func_08_plot_all_lineages_with_categories = function(seed_vec){
  # Load data
  df_summary = NA
  for(seed in seed_vec){
    df_seed_summary = load_lineage_processed_summary_with_categories(seed)
    df_seed_summary$seed = seed
    if(is.data.frame(df_summary)){
      df_summary = rbind(df_summary, df_seed_summary)
    } else {
      df_summary = df_seed_summary
    }
  }
  
  
  ggplot(df_summary, aes(x = depth, y = task_quality_mean)) + 
    geom_point(size = 0.5) +
    geom_point(data=df_summary[!is.na(df_summary$category),], aes(color = as.factor(category)), size = 0.75) + 
    scale_color_manual(values = category_color_map) +
    facet_wrap(vars(as.factor(seed)))
  ggsave(paste0(plot_dir, '/lineage_task_quality_mean_categorized.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, '/lineage_task_quality_mean_categorized.pdf'), units = 'in', width = 8, height = 6)
}