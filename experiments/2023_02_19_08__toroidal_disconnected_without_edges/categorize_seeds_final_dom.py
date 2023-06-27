import pygame
import os

num_maps = 4
num_seeds = 200

input_dir = './images/stitched'
input_str_prefix = input_dir + '/seed_'
input_str_suffix = '.png'

output_filename = './data/final_dom_categories.csv'

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

seed_map = {}
if os.path.isfile(output_filename):
    print('Output file already exists, reading in contents...')
    with open(output_filename, 'r') as fp:
        for line in fp:
            line = line.strip()
            if line == '' or line == '"seed","category"' or line == 'seed,category':
                continue
            line_parts = line.split(',')
            if len(line_parts) != 2:
                continue
            seed = int(line_parts[0].strip('"'))
            category = line_parts[1].strip('"')
            seed_map[seed] = category
    print(seed_map)

done = False
cur_seed = 0
is_seed_valid = False
while True:
    cur_seed += 1
    if cur_seed > num_seeds:
        done = True
        break
    elif cur_seed not in seed_map.keys():
        is_seed_valid = True
        break
input_filename = input_str_prefix + str(cur_seed).zfill(3) + input_str_suffix
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
                # Categorize current seed
                seed_map[cur_seed] = category_selected
                # Find next seed to categorize
                is_seed_valid = False
                while True:
                    cur_seed += 1
                    if cur_seed > num_seeds:
                        done = True
                        break
                    elif cur_seed not in seed_map.keys():
                        is_seed_valid = True
                        break
                if is_seed_valid:
                    input_filename = input_str_prefix + str(cur_seed).zfill(3) + input_str_suffix
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
    seed_surf = font.render('Seed: ' + str(cur_seed), True, (255,255,255))
    seed_rect = seed_surf.get_rect()
    seed_rect.bottomleft = (button_x, screen_height)
    screen.blit(seed_surf, seed_rect)

    pygame.display.flip()
    clock.tick(30)
    
pygame.quit()

with open(output_filename, 'w') as fp:
    fp.write('seed,category\n')
    sorted_seeds = sorted(seed_map.keys())
    for seed in sorted_seeds:
        fp.write('"' + str(seed) + '","' + seed_map[seed] + '"\n')
