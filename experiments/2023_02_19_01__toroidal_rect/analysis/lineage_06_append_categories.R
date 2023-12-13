source('shared_config_lineage.R')

lineage_func_06_append_categories = function(seed){
  # Load data
  df = load_lineage_processed_data(seed)
  df_summary = load_lineage_processed_summary(seed)
  df_category = load_lineage_category_data(seed)
  
  # Merge data
  df$category = NA
  df_summary$category = NA
  for(depth in df_category$depth){
    df_summary[df_summary$depth == depth,]$category = df_category[df_category$depth == depth,]$category
    df[df$depth == depth,]$category = df_category[df_category$depth == depth,]$category
  }
  
  data_filename = get_lineage_processed_data_with_categories_filename(seed)
  write.csv(df, data_filename)
  summary_filename = get_lineage_processed_summary_with_categories_filename(seed)
  write.csv(df_summary, summary_filename)
}