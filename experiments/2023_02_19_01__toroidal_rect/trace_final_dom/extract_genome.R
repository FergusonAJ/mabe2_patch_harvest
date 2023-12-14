rm(list = ls())

args = commandArgs(trailingOnly = T)
if(length(args) != 1){
  cat('Error! Expected exactly one command line argument:\n')
  cat('  1. The seed whose genome we want to extract:\n')
  q()
}
seed = as.numeric(args[1])

df_final_dom = read.csv('../data/processed/processed_final_dominant_data.csv')
genome_raw = df_final_dom[df_final_dom$seed == seed,]$genome[1]
genome = strsplit(genome_raw, ']')[[1]][2] 
cat(genome, '\n')
