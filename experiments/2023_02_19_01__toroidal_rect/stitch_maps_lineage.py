import pygame
import os
import math
import sys

# Config options
num_maps = 4

# Fetch seed number from the command line arguments
if(len(sys.argv) < 2):
    print('Error! Expected one command line argument:')
    print('  1. The seed to stitch')
    quit()
seed = sys.argv[1]
print('Stitching seed:', seed)


num_rows = int(math.ceil(num_maps**(0.5)))
num_cols = int(math.ceil(num_maps / num_rows))

input_dir = './images/reps/' + str(seed) 
input_str_prefix = input_dir + '/depth_'
input_str_middle = '__map_'
input_str_suffix = '.png'

output_dir = './images/stitched/reps/' + str(seed) 
output_str_prefix = output_dir + '/depth_'
output_str_suffix = '.png'
os.makedirs(output_dir, exist_ok=True)

depth_list = []
for filename in sorted(os.listdir(input_dir)):
    filename_parts = filename.split('_')
    if len(filename_parts) == 5 and filename_parts[-1] == '0.png':
        depth_list.append(int(filename_parts[1]))

pygame.init()

for depth in depth_list:
    images = []
    for map_idx in range(num_maps):
        input_filename = input_str_prefix + str(depth) + input_str_middle + str(map_idx) + input_str_suffix
        images.append(pygame.image.load(input_filename))
    img_width = 0
    img_height = 0
    # Calculate width
    for row in range(num_rows):
        row_width = 0
        for col in range(num_cols):
            idx = row * num_cols + col
            if idx < len(images):
                row_width += images[idx].get_width()
        if row_width > img_width:
            img_width = row_width
    # Calculate height 
    for col in range(num_cols):
        col_height = 0
        for row in range(num_rows):
            idx = row * num_cols + col
            if idx < len(images):
                col_height += images[idx].get_height()
        if col_height > img_height:
            img_height = col_height
    surf = pygame.Surface((img_width, img_height))
    for row in range(num_rows):
        row_y = int(row * (img_height / num_rows))
        for col in range(num_cols):
            col_x = int(col * (img_width / num_cols))
            idx = row * num_cols + col
            if idx >= len(images):
                continue
            surf.blit(images[idx], (col_x, row_y))
    padded_depth = str(depth).zfill(4)
    output_filename = output_str_prefix + padded_depth + output_str_suffix
    pygame.image.save(surf, output_filename)
    print('Stitched', padded_depth)        
