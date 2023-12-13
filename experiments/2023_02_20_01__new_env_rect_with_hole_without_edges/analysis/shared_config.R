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
plot_dir = '../plots/'
if(!dir.exists(plot_dir)){
  cat('Plot directory does not exist. Creating: ', plot_dir, '\n')
  dir.create(plot_dir)
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
