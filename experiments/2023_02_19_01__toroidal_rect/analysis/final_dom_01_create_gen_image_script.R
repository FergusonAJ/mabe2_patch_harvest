rm(list = ls())

source('./shared_config.R')

regen = T

df = load_final_dom_processed_data()

# Create image generation script to plot all paths
image_gen_script_filename = paste0(script_dir, '/generate_images.sh')
if(!file.exists(image_gen_script_filename) | regen){
  # Fetch map prefix
  map_0 = list.files('../shared_files/maps/')[1]
  map_prefix = strsplit(map_0, '0')[[1]][1]
  
  image_output_dir = 'images/'
  image_output_dir_from_here = paste0('../', image_output_dir)
  if(!dir.exists(image_output_dir_from_here)){
    cat('Plot directory does not exist. Creating: ', image_output_dir_from_here, '\n')
    dir.create(image_output_dir_from_here)
  }
  gif_tmp_dir = 'gif_tmp/'
  gif_tmp_dir_from_here = paste0('../', gif_tmp_dir)
  if(!dir.exists(gif_tmp_dir_from_here)){
    cat('Temporary gif directory does not exist. Creating: ', gif_tmp_dir_from_here, '\n')
    dir.create(gif_tmp_dir_from_here)
  }
  gif_output_dir = paste0(image_output_dir, 'gifs/')
  gif_output_dir_from_here = paste0('../', gif_output_dir)
  if(!dir.exists(gif_output_dir_from_here)){
    cat('Plot directory does not exist. Creating: ', gif_output_dir_from_here, '\n')
    dir.create(gif_output_dir_from_here)
  }

  output_str = ''
  output_str = paste0(output_str, '#!/bin/bash\n\n')
  for(seed in unique(df$seed)){
    cat(seed, ' ')
    for(map_idx in unique(df$map_idx)){
      row = df[df$seed == seed & df$map_idx == map_idx,][1,]
      local_str = ''
      local_str = paste0(local_str, 'python3 ../../MABE2_extras/scripts/visualization/eval_patch_harvest.py')
      local_str = paste0(local_str, ' shared_files/maps/', map_prefix, map_idx, '.txt')
      local_str = paste0(local_str, ' ', row$movements)
      local_str = paste0(local_str, ' ', image_output_dir, 'seed_', seed, '__map_', map_idx, '.png gif_tmp\n')
      local_str = paste0(local_str, 'cd ', gif_tmp_dir, '\n')
      #local_str = paste0(local_str, 'convert -resize 50% -delay 10 -loop 1 frame_* ../', gif_output_dir, 'seed_', seed, '__map_', map_idx, '.mp4\n')
      local_str = paste0(local_str, 'ffmpeg -framerate 60 -pattern_type glob -i \'frame*.png\' ', '../', gif_output_dir, 'seed_', seed, '__map_', map_idx, '.mp4\n')
      local_str = paste0(local_str, 'rm frame*.png\n')
      local_str = paste0(local_str, 'cd ..\n')
      output_str = paste0(output_str, local_str)
    }
  }
  write(output_str, image_gen_script_filename)
  cat('\n')
  system(paste0('chmod u+x ',image_gen_script_filename))
}
