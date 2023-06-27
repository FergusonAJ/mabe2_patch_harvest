source('shared_config_lineage.R')

lineage_func_02_create_replay_script = function(seed, regen = F){
  # Load data
  df = load_lineage_processed_data(seed)
  
  # Create bash script to play any depth on any map 
  rep_scripts_dir = get_lineage_scripts_dir(seed)
  replay_script_filename = paste0(rep_scripts_dir, 'replay_', seed, '.sh')
  if(!file.exists(replay_script_filename) | regen){
    # Fetch map prefix
    map_0 = list.files('../shared_files/maps/')[1]
    map_prefix = strsplit(map_0, '0')[[1]][1]
    
    output_str = ''
    output_str = paste0(output_str, '#!/bin/bash\n\n')
    output_str = paste0(output_str, 'if [ ! "$#" -eq 2 ]\n')
    output_str = paste0(output_str, 'then\n')
    output_str = paste0(output_str, '  echo "Two arguments required: the depth and map you wish to run"\n')
    output_str = paste0(output_str, '  exit 1\n')
    output_str = paste0(output_str, 'fi\n\n')
   
    max_depth = max(df$depth) 
    last_tenth = 0
    for(depth in unique(df$depth)){
      if(depth / max_depth >= last_tenth + 0.1){
        last_tenth = round(depth / max_depth, 1)
        cat(last_tenth, ' ')
      }
      output_str = paste0(output_str, '  if [ "$1" -eq ', depth,' ]\n')
      output_str = paste0(output_str, '  then\n')
      for(map_idx in unique(df$map_idx)){
        row = df[df$depth == depth & df$map_idx == map_idx,][1,]
        output_str = paste0(output_str, '    if [ "$2" -eq ', map_idx,' ]\n')
        output_str = paste0(output_str, '    then\n')
        output_str = paste0(output_str, '      python3 ../../MABE2_extras/scripts/visualization/eval_patch_harvest.py')
        output_str = paste0(output_str, ' shared_files/maps/', map_prefix, map_idx, '.txt')
        output_str = paste0(output_str, ' ', row$movements, '\n')
        output_str = paste0(output_str, '    fi\n')
      }
      output_str = paste0(output_str, '  fi\n')
    }
    write(output_str, replay_script_filename)
    system(paste0('chmod u+x ', replay_script_filename))
    cat('\n')
  }
}