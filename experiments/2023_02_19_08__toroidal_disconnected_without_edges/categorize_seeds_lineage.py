import pygame
import os
import sys

# Config options
num_maps = 4

# Fetch seed number from the command line arguments
if(len(sys.argv) < 2):
    print('Error! Expected one command line argument:')
    print('  1. The seed to categorize')
    quit()
seed = sys.argv[1]
print('Stitching seed:', seed)

input_dir = './images/stitched/reps/' + str(seed)
input_str_prefix = input_dir + '/depth_'
input_str_suffix = '.png'

depth_list = []
for filename in os.listdir(input_dir):
    filename_parts = filename.split('_')
    if len(filename_parts) == 2:
        depth_list.append(int(filename_parts[1].split('.')[0]))
depth_list.sort()

output_filename = './data/reps/' + str(seed) + '/depth_categories.csv'

categories = [\
        'Spiraling',
        'Plowing', 
        'Reactive meandering', 
        'Pattern cycling', 
        'Set pattern', 
        'Loop',
        'None'
        ]

screen_width = 1200
screen_height = 800
img_width = 800
img_height = 800

pygame.init()
screen = pygame.display.set_mode((screen_width, screen_height))

button_x = img_width + 100
button_width = screen_width - img_width - 100
button_height = 30
button_rects = []
for i in range(len(categories)):
    rect = pygame.Rect(img_width + 100, i * button_height + i, button_width, button_height)
    button_rects.append(rect)

font = pygame.font.SysFont('ubuntu', button_height - 4)

clock = pygame.time.Clock()

depth_map = {}
if os.path.isfile(output_filename):
    print('Output file already exists, reading in contents...')
    with open(output_filename, 'r') as fp:
        for line in fp:
            line = line.strip()
            if line == '' or line == '"depth","category"' or line == 'depth,category':
                continue
            line_parts = line.split(',')
            if len(line_parts) != 2:
                continue
            depth = int(line_parts[0].strip('"'))
            category = line_parts[1].strip('"')
            depth_map[depth] = category
    print(depth_map)

done = False
cur_depth_idx = 0
is_depth_valid = False
while True:
    cur_depth_idx += 1
    if cur_depth_idx >= len(depth_list):
        done = True
        print('\nAll depths categorized, exiting!')
        break
    cur_depth = depth_list[cur_depth_idx]
    if cur_depth not in depth_map.keys():
        is_depth_valid = True
        break
input_filename = input_str_prefix + str(cur_depth).zfill(4) + input_str_suffix
cur_image_raw = pygame.image.load(input_filename)
cur_image = pygame.transform.scale(cur_image_raw, (img_width, img_height))
while not done:
    mouse_x, mouse_y = pygame.mouse.get_pos()
    event_list = pygame.event.get()
    for event in event_list:
        if event.type == pygame.QUIT:
            done = True
        elif event.type == pygame.KEYDOWN:
            if event.key == pygame.K_q or event.key == pygame.K_ESCAPE:
                done = True
        elif event.type == pygame.MOUSEBUTTONUP:
            category_selected = None
            for i, category in enumerate(categories):
                if button_rects[i].collidepoint(mouse_x, mouse_y):
                    category_selected = category
            if category_selected is not None:
                # Categorize current depth
                depth_map[cur_depth] = category_selected
                # Find next depth to categorize
                is_depth_valid = False
                while True:
                    cur_depth_idx += 1
                    if cur_depth_idx >= len(depth_list):
                        done = True
                        print('\nAll depths categorized, exiting!')
                        break
                    cur_depth = depth_list[cur_depth_idx]
                    if cur_depth not in depth_map.keys():
                        is_depth_valid = True
                        break
                if is_depth_valid:
                    input_filename = input_str_prefix + str(cur_depth).zfill(4) + input_str_suffix
                    cur_image_raw = pygame.image.load(input_filename)
                    cur_image = pygame.transform.scale(cur_image_raw, (img_width, img_height))

        
    screen.fill((0,0,0))
    screen.blit(cur_image, (0,0) )
    for i, category in enumerate(categories):
        rect_color = (150,150,150)
        if button_rects[i].collidepoint(mouse_x, mouse_y):
            rect_color = (200,200,200)
        pygame.draw.rect(screen, rect_color, button_rects[i]) 
        text_surf = font.render(category, True, (0,0,0))
        text_rect = text_surf.get_rect()
        text_rect.center = button_rects[i].center
        screen.blit(text_surf, text_rect)
    depth_surf = font.render('Depth: ' + str(cur_depth), True, (255,255,255))
    depth_rect = depth_surf.get_rect()
    depth_rect.bottomleft = (button_x, screen_height)
    screen.blit(depth_surf, depth_rect)

    pygame.display.flip()
    clock.tick(30)
    
pygame.quit()

with open(output_filename, 'w') as fp:
    fp.write('depth,category\n')
    sorted_depths = sorted(depth_map.keys())
    for depth in sorted_depths:
        fp.write('"' + str(depth) + '","' + depth_map[depth] + '"\n')
