import pygame
import os
import math

num_maps = 4
num_seeds = 200
num_rows = int(math.ceil(num_maps**(0.5)))
num_cols = int(math.ceil(num_maps / num_rows))

input_str_prefix = './images/seed_'
input_str_middle = '__map_'
input_str_suffix = '.png'

output_dir = './images/stitched'
output_str_prefix = output_dir + '/seed_'
output_str_suffix = '.png'
os.makedirs(output_dir, exist_ok=True)

pygame.init()

for seed in range(1, num_seeds+1):
    images = []
    for map_idx in range(num_maps):
        input_filename = input_str_prefix + str(seed) + input_str_middle + str(map_idx) + input_str_suffix
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
    padded_seed = str(seed).zfill(3)
    output_filename = output_str_prefix + padded_seed + output_str_suffix
    pygame.image.save(surf, output_filename)
    print('Stitched', padded_seed)        
