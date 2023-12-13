rm(list = ls())

source('./shared_config.R')

df = load_final_dom_processed_data()
df_summary = load_final_dom_processed_summary()
df_map_summary = load_final_dom_processed_map_summary()
df_category = load_final_dom_category_data()

df$category = NA
df_summary$category = NA
df_map_summary$category = NA
for(category in unique(df_category$category)){
  seed_vec = df_category[df_category$category == category,]$seed
  df[df$seed %in% seed_vec,]$category = category
  df_summary[df_summary$seed %in% seed_vec,]$category = category
  df_map_summary[df_map_summary$seed %in% seed_vec,]$category = category
}
for(missing_seed in unique(df_summary[is.na(df_summary$category),]$seed)){
  cat('Warning! Seed', missing_seed, 'has not been classified!\n')
}

write.csv(df, get_final_dom_categorized_data_filename(), row.names = F)
write.csv(df_summary, get_final_dom_categorized_summary_filename(), row.names = F)
write.csv(df_map_summary, get_final_dom_categorized_map_summary_filename(), row.names = F)
