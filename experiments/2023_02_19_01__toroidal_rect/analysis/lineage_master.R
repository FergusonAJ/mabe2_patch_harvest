rm(list = ls())

source('lineage_master_include.R')

# Category: Pattern cycling 
#   157 2.404261e+32 
#   196 5.617334e+30 
#   119 8.666525e+27 
# Category: Set pattern 
#   194 2.824178e+23 
#   172 4.816833e+22 
#   107 1.329897e+22 
# Category: Reactive meandering 
#   115 2.444036e+20 
#   79 1.791723e+19 
#   189 1.692397e+17 
# Category: Plowing 
#   11 4.865889e+19

processed_seeds = c(
  157, 196, 119, # Pattern cycling
  194, 172, 107, # Set pattern
  115, 79, 189, # Reactive meandering
  11 # Plowing
)
regen = F

for(seed in c(1)){#140, 144, 196)){
  lineage_func_00_analyze_lineage(seed)
  lineage_func_01_create_gen_image_script(seed, regen)
  lineage_func_02_create_replay_script(seed, regen)
  lineage_func_03_create_gen_notable_image_script(seed, regen)
  lineage_func_04_plot_lineage(seed)
  lineage_func_05_create_category_file(seed)
  #lineage_func_06_append_categories(seed)
  #lineage_func_07_plot_lineage_with_categories(seed)
}

#lineage_func_08_plot_all_lineages_with_categories(processed_seeds)
