rm(list = ls())

source('./shared_config.R')

# Load data
df_summary = load_final_dom_categorized_summary()

for(category in unique(df_summary$category)){
  cat('Category:', category, '\n')
  df_category = df_summary[df_summary$category == category,]
  df_category = df_category[order(df_category$merit_mean, decreasing=T),]
  for(i in seq(1, min(3, nrow(df_category)))){
    cat(' ', df_category[i,]$seed, df_category[i,]$merit_mean, '\n')
  }
}