library(ggplot2)
library(dplyr)
source("https://gist.githubusercontent.com/benmarwick/2a1bb0133ff568cbe28d/raw/fb53bd97121f7f9ce947837ef1a4c65a73bffb3f/geom_flat_violin.R")

# Data directories
data_dir = '../data'
processed_data_dir = '../data/processed'
if(!dir.exists(processed_data_dir)){
  cat('Processed directory does not exist. Creating: ', processed_data_dir, '\n')
  dir.create(processed_data_dir)
}
plot_dir = '../plots'
if(!dir.exists(plot_dir)){
  cat('Plot directory does not exist. Creating: ', plot_dir, '\n')
  dir.create(plot_dir)
}
image_dir = '../images'
if(!dir.exists(image_dir)){
  cat('Image directory does not exist. Creating: ', image_dir, '\n')
  dir.create(image_dir)
}
script_dir = '../scripts'
if(!dir.exists(script_dir)){
  cat('Script directory does not exist. Creating: ', script_dir, '\n')
  dir.create(script_dir)
}

category_color_map = c(
  'Spiraling' = '#4477AA', 
  'Plowing' = '#EE6677', 
  'Reactive meandering' = '#CCBB44', 
  'Pattern cycling' = '#228833', 
  'Set pattern' = '#AA3377', 
  'Loop' ='#66CCEE', 
  'None' = '#BBBBBB'
)

# Extra color: '#66CCEE' 

# Filenames
get_final_dom_raw_data_filename = function(){
  filename = paste0(data_dir, '/combined_final_dominant_data.csv')
  return(filename)
}
get_final_dom_processed_data_filename = function(){
  filename = paste0(processed_data_dir, '/processed_final_dominant_data.csv')
  return(filename)
}
get_final_dom_processed_summary_filename = function(){
  filename = paste0(processed_data_dir, '/processed_final_dominant_summary.csv')
  return(filename)
}
get_final_dom_processed_map_summary_filename = function(){
  filename = paste0(processed_data_dir, '/processed_final_dominant_map_summary.csv')
  return(filename)
}
get_final_dom_category_data_filename = function(){
  filename = paste0(data_dir, '/final_dom_categories.csv')
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
load_final_dom_processed_data = function(){
  filename = get_final_dom_processed_data_filename()
  return(load_file(filename))
}
load_final_dom_processed_summary = function(){
  filename = get_final_dom_processed_summary_filename()
  return(load_file(filename))
}
load_final_dom_processed_map_summary = function(){
  filename = get_final_dom_processed_map_summary_filename()
  return(load_file(filename))
}
load_final_dom_category_data = function(){
  filename = get_final_dom_category_filename()
  return(load_file(filename))
}
