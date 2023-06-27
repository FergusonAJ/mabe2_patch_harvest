rm(list = ls())

source('lineage_master_include.R')

seed = 31
regen = F

lineage_func_00_analyze_lineage(seed)
lineage_func_01_create_gen_image_script(seed, regen)
lineage_func_02_create_replay_script(seed, regen)
lineage_func_03_create_gen_notable_image_script(seed, regen)
lineage_func_04_plot_lineage(seed)
lineage_func_05_create_category_file(seed)
lineage_func_06_append_categories(seed)
lineage_func_07_plot_lineage_with_categories(seed)
