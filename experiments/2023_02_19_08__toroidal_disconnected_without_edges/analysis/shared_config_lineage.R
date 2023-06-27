source('shared_config.R')

# Directory getters
get_lineage_plot_dir = function(seed){
  plot_dir = paste0(plot_dir, '/reps/', seed,'/')
  if(!dir.exists(plot_dir)){
    dir.create(plot_dir, recursive = T)
  }
  return(plot_dir)
}
get_lineage_scripts_dir = function(seed){
  scripts_dir = paste0('../scripts/reps/')
  rep_scripts_dir = paste0(scripts_dir, seed, '/')
  if(!dir.exists(rep_scripts_dir)){
    dir.create(rep_scripts_dir, recursive = T)
  }
  return(rep_scripts_dir) 
}
get_lineage_data_dir = function(seed){
  rep_data_dir = paste0(data_dir, '/reps/', seed)
  if(!dir.exists(rep_data_dir)){
    dir.create(rep_data_dir, recursive = T)
  }
  return(rep_data_dir)
}
get_lineage_processed_data_dir = function(seed){
  rep_data_dir = get_lineage_data_dir(seed)
  rep_processed_data_dir = paste0(rep_data_dir, '/processed')
  if(!dir.exists(rep_processed_data_dir)){
    dir.create(rep_processed_data_dir, recursive = T)
  }
  return(rep_processed_data_dir) 
}
get_lineage_image_dir = function(seed){
  rep_image_dir = paste0(image_dir, '/reps/', seed)
  if(!dir.exists(rep_image_dir)){
    dir.create(rep_image_dir, recursive = T)
  }
  return(rep_image_dir) 
}

# Filename getters
get_lineage_base_data_filename = function(seed){
  rep_data_dir = get_lineage_data_dir(seed)
  filename = paste0(rep_data_dir, '/dominant_lineage_summary.csv')
  return(filename) 
}
get_lineage_processed_data_filename = function(seed){
  rep_processed_data_dir = get_lineage_processed_data_dir(seed)
  filename = paste0(rep_processed_data_dir, '/processed_lineage_data.csv')
  return(filename) 
}
get_lineage_processed_summary_filename = function(seed){
  rep_processed_data_dir = get_lineage_processed_data_dir(seed)
  filename = paste0(rep_processed_data_dir, '/processed_lineage_summary.csv')
  return(filename) 
}
get_lineage_processed_data_with_categories_filename = function(seed){
  rep_processed_data_dir = get_lineage_processed_data_dir(seed)
  filename = paste0(rep_processed_data_dir, '/processed_lineage_data_with_categories.csv')
  return(filename) 
}
get_lineage_processed_summary_with_categories_filename = function(seed){
  rep_processed_data_dir = get_lineage_processed_data_dir(seed)
  filename = paste0(rep_processed_data_dir, '/processed_lineage_summary_with_categories.csv')
  return(filename) 
}
get_lineage_category_filename = function(seed){
  rep_data_dir = get_lineage_data_dir(seed)
  filename = paste0(rep_data_dir, '/depth_categories.csv')
  return(filename) 
}

# Data loaders
load_file = function(filename){
  if(!file.exists(filename)){
    cat('Error! Data file does not exist: ', filename)
    cat(' Exiting!\n')
    quit()
  }
  return(read.csv(filename)) 
}
load_lineage_base_data = function(seed){
  filename = get_lineage_base_data_filename(seed)
  return(load_file(filename))
}
load_lineage_processed_data = function(seed){
  filename = get_lineage_processed_data_filename(seed)
  return(load_file(filename)) 
}
load_lineage_processed_summary = function(seed){
  filename = get_lineage_processed_summary_filename(seed)
  return(load_file(filename)) 
}
load_lineage_category_data = function(seed){
  filename = get_lineage_category_filename(seed)
  return(load_file(filename)) 
}
load_lineage_processed_data_with_categories = function(seed){
  filename = get_lineage_processed_data_with_categories_filename(seed)
  return(load_file(filename)) 
}
load_lineage_processed_summary_with_categories = function(seed){
  filename = get_lineage_processed_summary_with_categories_filename(seed)
  return(load_file(filename)) 
}
