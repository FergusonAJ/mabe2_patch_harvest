rm(list = ls())

source('./shared_config.R')

regen = T

df = load_final_dom_processed_data()

# Create bash script to play any seed on any map 
replay_script_filename = paste0(script_dir, '/replay.sh')
if(!file.exists(replay_script_filename)){
  # Fetch map prefix
  map_0 = list.files('../shared_files/maps/')[1]
  map_prefix = strsplit(map_0, '0')[[1]][1]
  
  output_str = ''
  output_str = paste0(output_str, '#!/bin/bash\n\n')
  output_str = paste0(output_str, 'if [ ! "$#" -eq 2 ]\n')
  output_str = paste0(output_str, 'then\n')
  output_str = paste0(output_str, '  echo "Two arguments required: the seed and map you wish to run"\n')
  output_str = paste0(output_str, '  exit 1\n')
  output_str = paste0(output_str, 'fi\n\n')
  
  for(seed in unique(df$seed)){
    cat(seed, ' ')
    local_str = ''
    local_str = paste0(local_str, '  if [ "$1" -eq ', seed,' ]\n')
    local_str = paste0(local_str, '  then\n')
    for(map_idx in unique(df$map_idx)){
      row = df[df$seed == seed & df$map_idx == map_idx,][1,]
      local_str = paste0(local_str, '    if [ "$2" -eq ', map_idx,' ]\n')
      local_str = paste0(local_str, '    then\n')
      local_str = paste0(local_str, '      python3 ../../MABE2_extras/scripts/visualization/eval_patch_harvest.py')
      local_str = paste0(local_str, ' shared_files/maps/', map_prefix, map_idx, '.txt')
      local_str = paste0(local_str, ' ', row$movements, '\n')
      local_str = paste0(local_str, '    fi\n')
    }
    local_str = paste0(local_str, '  fi\n')
    output_str = paste0(output_str, local_str)
  }
  write(output_str, replay_script_filename)
  system(paste0('chmod u+x ', replay_script_filename))
  cat('\n')
}