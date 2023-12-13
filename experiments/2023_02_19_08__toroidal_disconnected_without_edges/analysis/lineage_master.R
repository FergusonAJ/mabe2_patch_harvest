rm(list = ls())

source('lineage_master_include.R')

#Category: Pattern cycling 
# X 140 580757330 
# X 144 84732266 
# X 196 29857883 
#Category: Reactive meandering 
# X 182 17252003 
# X 158 1033120 
# X 42 878454.6 
#Category: Loop 
# X 17 29850526 
# X 109 28802536 
# X 150 19783108 
#Category: Plowing 
# X 134 11698808 
# X 179 7465285 
# X 85 7170370 
#Category: Spiraling 
# X 38 2.584248e+19 
# X 32 1.20561e+16 
# X 31 4.845041e+13 

processed_seeds = c(
  140, 144, 196, # Pattern cycling
  182, 158, 42, # Reactive meandering
  17, 109, 150, # Loop
  134, 179, 85, # Plowing
  38, 32, 31 # Spiraling
)
regen = F

for(seed in c()){#140, 144, 196)){
  lineage_func_00_analyze_lineage(seed)
  lineage_func_01_create_gen_image_script(seed, regen)
  lineage_func_02_create_replay_script(seed, regen)
  lineage_func_03_create_gen_notable_image_script(seed, regen)
  lineage_func_04_plot_lineage(seed)
  lineage_func_05_create_category_file(seed)
  lineage_func_06_append_categories(seed)
  lineage_func_07_plot_lineage_with_categories(seed)
}

lineage_func_08_plot_all_lineages_with_categories(processed_seeds)
