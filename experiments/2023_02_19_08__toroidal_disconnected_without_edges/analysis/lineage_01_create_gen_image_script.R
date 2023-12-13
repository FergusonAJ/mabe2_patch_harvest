source('shared_config_lineage.R')

lineage_func_01_create_gen_image_script = function(seed, regen = F){
  # Load data
  df = load_lineage_processed_data(seed)
  
  # Create image generation script to plot all paths
  rep_scripts_dir = get_lineage_scripts_dir(seed)
  image_gen_script_filename = paste0(rep_scripts_dir, 'generate_images_', seed, '.sh')
  if(!file.exists(image_gen_script_filename) | regen){
    # Fetch map prefix
    map_0 = list.files('../shared_files/maps/')[1]
    map_prefix = strsplit(map_0, '0')[[1]][1]
    
    image_output_dir = get_lineage_image_dir(seed)
    image_output_dir_from_here = paste0('../', image_output_dir)
    if(!dir.exists(image_output_dir_from_here)){
      cat('Image directory does not exist. Creating: ', image_output_dir_from_here, '\n')
      dir.create(image_output_dir_from_here, recursive = T)
    }
  
    output_str = ''
    output_str = paste0(output_str, '#!/bin/bash\n\n')
    max_depth = max(df$depth)
    last_tenth = 0
    for(depth in unique(df$depth)){
      local_str = ''
      if(depth / max_depth >= last_tenth + 0.1){
        last_tenth = round(depth / max_depth, 1)
        cat(last_tenth, ' ')
      }
      for(map_idx in unique(df$map_idx)){
        row = df[df$depth == depth & df$map_idx == map_idx,][1,]
        local_str = paste0(local_str, 'python3 ../../MABE2_extras/scripts/visualization/eval_patch_harvest.py')
        local_str = paste0(local_str, ' shared_files/maps/', map_prefix, map_idx, '.txt')
        local_str = paste0(local_str, ' ', row$movements)
        local_str = paste0(local_str, ' ', image_output_dir, 'depth_', depth, '__map_', map_idx, '.png\n') # gif_tmp\n')
      }
      output_str = paste0(output_str, local_str)
    }
    write(output_str, image_gen_script_filename)
    system(paste0('chmod u+x ', image_gen_script_filename))
    cat('\n')
  }
}