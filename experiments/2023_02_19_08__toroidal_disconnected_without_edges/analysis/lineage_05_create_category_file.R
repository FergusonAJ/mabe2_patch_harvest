source('shared_config_lineage.R')

lineage_func_05_create_category_file = function(seed){
  # Load data
  df = load_lineage_processed_data(seed)
  
  category_filename = get_lineage_category_filename(seed)
  
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
    write.csv(df_category, category_filename, row.names = F)
  }
}