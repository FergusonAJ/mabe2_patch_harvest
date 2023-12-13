rm(list = ls())

source('./shared_config.R')

df = load_final_dom_processed_data()
df_summary = load_final_dom_processed_summary()
df_map_summary = load_final_dom_processed_map_summary()

category_filename = get_final_dom_category_data_filename()
if(file.exists(category_filename)){
  df_category = load_final_dom_category_data()
} else {
  df_category = data.frame(data = matrix(nrow = 0, ncol = 2))
  for(seed in unique(df$seed)){
    df_seed = df[df$seed == seed,]  
    if(length(unique(df_seed$movements)) == 1){
      df_category[nrow(df_category) + 1,] = c(seed, 'Set pattern')
    }
  }
  colnames(df_category) = c('seed', 'category')
  df_category$seed = as.numeric(df_category$seed)
}
write.csv(df_category, get_final_dom_category_data_filename(), row.names = F)
cat('File saved to: ', get_final_dom_category_data_filename(), '\n')
if(nrow(df_category) != nrow(df_summary)){
  cat('Some seeds still need to be categorized. Please run categorize_seeds_final_dom.py!\n') 
}