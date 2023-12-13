library(ggplot2)

source('shared_config_lineage.R')

lineage_func_08_plot_all_lineages_with_categories = function(seed_vec){
  # Load data
  df_summary = NA
  count_map = c(
    'Plowing' = 0,
    'Spiraling' = 0,
    'Reactive meandering' = 0,
    'Set pattern' = 0,
    'Loop' = 0,
    'None' = 0,
    'Pattern cycling' = 0
  )
  for(seed in seed_vec){
    df_seed_summary = load_lineage_processed_summary_with_categories(seed)
    df_seed_summary$seed = seed
    final_category = df_seed_summary[df_seed_summary$depth == max(df_seed_summary$depth),]$category
    count_map[final_category] = count_map[final_category] + 1
    df_seed_summary$index_in_category = count_map[final_category] 
    df_seed_summary$final_category = final_category
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
  
  ggplot(df_summary, aes(x = depth, y = task_quality_mean)) + 
    geom_point(size = 0.9) +
    geom_point(data=df_summary[!is.na(df_summary$category),], aes(color = as.factor(category)), size = 0.75) + 
    scale_color_manual(values = category_color_map) +
    facet_grid(rows = vars(as.factor(final_category)), cols = vars(index_in_category))
  ggsave(paste0(plot_dir, '/lineage_task_quality_mean_categorized__grid.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, '/lineage_task_quality_mean_categorized__grid.pdf'), units = 'in', width = 8, height = 6)
  
  ggplot(df_summary, aes(x = depth, y = task_quality_mean)) + 
    geom_point(size = 0.9) +
    geom_point(data=df_summary[!is.na(df_summary$category),], aes(color = as.factor(category)), size = 0.75) + 
    scale_color_manual(values = category_color_map) +
    facet_grid(cols = vars(as.factor(final_category)), rows = vars(index_in_category))
  ggsave(paste0(plot_dir, '/lineage_task_quality_mean_categorized__grid_flip.png'), units = 'in', width = 8, height = 6)
  ggsave(paste0(plot_dir, '/lineage_task_quality_mean_categorized__grid_flip.pdf'), units = 'in', width = 8, height = 6)
}
