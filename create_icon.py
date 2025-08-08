from PIL import Image, ImageDraw
import math

# Create a 1024x1024 image
size = 1024
img = Image.new('RGBA', (size, size), (245, 245, 220, 255))  # Beige background
draw = ImageDraw.Draw(img)

# Colors
sun_color = (255, 165, 0, 255)  # Orange
clock_color = (11, 61, 102, 255)  # Dark blue
white = (255, 255, 255, 255)

# Draw sun rays
center_x, center_y = size // 2, 380
sun_radius = 180

# Draw sun rays
for angle in range(0, 360, 30):
    rad = math.radians(angle)
    if angle % 60 == 0:  # Longer rays
        start_r = sun_radius + 20
        end_r = sun_radius + 140
    else:  # Shorter rays
        start_r = sun_radius + 20
        end_r = sun_radius + 80
    
    x1 = center_x + start_r * math.cos(rad)
    y1 = center_y + start_r * math.sin(rad)
    x2 = center_x + end_r * math.cos(rad)
    y2 = center_y + end_r * math.sin(rad)
    
    draw.line([(x1, y1), (x2, y2)], fill=sun_color, width=24)

# Draw sun circle
draw.ellipse([center_x - sun_radius, center_y - sun_radius, 
              center_x + sun_radius, center_y + sun_radius], 
             fill=sun_color)

# Draw clock (half circle)
clock_center_y = 700
clock_radius = 312

# Draw clock arc (outer ring)
for y in range(500, 800):
    x_dist = math.sqrt(max(0, clock_radius**2 - (y - clock_center_y)**2))
    if y >= 500:
        draw.line([(center_x - x_dist, y), (center_x + x_dist, y)], 
                 fill=clock_color, width=2)

# Draw white clock face
inner_radius = 272
for y in range(520, 780):
    x_dist = math.sqrt(max(0, inner_radius**2 - (y - clock_center_y)**2))
    if y >= 520 and x_dist > 0:
        draw.line([(center_x - x_dist + 20, y), (center_x + x_dist - 20, y)], 
                 fill=white, width=2)

# Draw clock hands
# Hour hand (pointing to 10)
hour_angle = math.radians(-120)  # 10 o'clock
hour_length = 120
hour_x = center_x + hour_length * math.cos(hour_angle)
hour_y = clock_center_y + hour_length * math.sin(hour_angle)
draw.line([(center_x, clock_center_y), (hour_x, hour_y)], 
         fill=clock_color, width=16)

# Minute hand (pointing to 2)
minute_angle = math.radians(-30)  # 2 position
minute_length = 120
minute_x = center_x + minute_length * math.cos(minute_angle)
minute_y = clock_center_y + minute_length * math.sin(minute_angle)
draw.line([(center_x, clock_center_y), (minute_x, minute_y)], 
         fill=clock_color, width=16)

# Draw center dot
draw.ellipse([center_x - 20, clock_center_y - 20,
              center_x + 20, clock_center_y + 20],
             fill=clock_color)

# Draw clock marks
# 12 o'clock mark
draw.rectangle([center_x - 6, 530, center_x + 6, 570], fill=clock_color)

# Save the image
img.save('/Users/ech/Documents/Programacion/IZmanim/zmanim_app/assets/icon/icon.png')
print("Icon created successfully!")