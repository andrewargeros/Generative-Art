# Packages ----------------------------------------------------------------------------------------
library(mathart) # devtools::install_github("marcusvolz/mathart")
library(tidyverse)
library(tweenr)
library(glue)

# Parameters --------------------------------------------------------------------------------------
n = 10000 # iterations
r = 75 # neighbourhood
width_in = 11 # canvas width in inches
height_in = 8.5 # canvas height in inches
delta = 2 * pi / 180 # angle direction noise
p_branch = 0.1 # probability of branching
initial_pts = 3 # number of initial points
save_dir = "C:/RScripts" # directory to save plot

# Setup Tibbles for Storage -----------------------------------------------------------------------
points = tibble(x = numeric(n), y = numeric(n), dir = numeric(n), level = integer(n))
edges = tibble(x = numeric(n), y = numeric(n), xend = numeric(n), yend = numeric(n), level = integer(n))

# Make Initial Points -----------------------------------------------------------------------------
if(initial_pts > 1) {
  i = 2
  while(i <= initial_pts) {
    points[i, ] = c(runif(1, 0, width), runif(1, 0, height), runif(1, -2*pi, 2*pi), 1)
    i = i + 1
  }
}
t0 = Sys.time()

# Main Generation Function ------------------------------------------------------------------------
make_lines = function(points, edges, n, r, delta, width_in, height_in, p_branch, initial_pts){
  width = width_in * 1000
  height = height_in * 1000
  i = initial_pts + 1
  while (i <= n) {
    valid = FALSE
    while (!valid) {
      random_point = sample_n(points[seq(1:(i-1)), ], 1) # Pick a point at random
      
      branch = runif(1, 0, 1) <= p_branch # Should the line branch?
      
      alpha = random_point$dir[1] + runif(1, -(delta), delta) + (branch * (ifelse(runif(1, 0, 1) < 0.5, -1, 1) * pi/2))
      
      v = c(cos(alpha), sin(alpha)) * r * (1 + 1 / ifelse(branch, random_point$level[1]+1, random_point$level[1])) # Create directional vector
      xj = random_point$x[1] + v[1]
      yj = random_point$y[1] + v[2]
      lvl = random_point$level[1]
      lvl_new = ifelse(branch, lvl+1, lvl)
      if(xj < 0 | xj > width | yj < 0 | yj > height) { # Check if a valid point
        next
      }
      points_dist = points %>% mutate(d = sqrt((xj - x)^2 + (yj - y)^2))
      if (min(points_dist$d) >= 1 * r) {
        points[i, ] = c(xj, yj, alpha, lvl_new)
        edges[i, ] = c(xj, yj, random_point$x[1], random_point$y[1], lvl_new)
        valid = TRUE
      }
    }
    i = i + 1
    paste0(i, " / ", n)
  }
  return(edges %>% filter(level > 0))
}

# Plot --------------------------------------------------------------------------------------------
plot = points %>% 
  make_lines(edges, n, r, delta, width_in, height_in, p_branch, initial_pts) %>% 
  ggplot() +
  aes(x, y, xend = xend, yend = yend, size = -level, color = level) +
  geom_segment(lineend = "round", show.legend = F) +
  scale_color_viridis_c(begin = 0.05, end = 0.85) + # change the color if you want 
  xlim(0, width_in*1000) +
  ylim(0, height_in*1000) +
  coord_equal() +
  scale_size_continuous(range = c(0.5, 0.5)) +
  theme_blankcanvas(bg_col = "#d2e7f5", margin_cm = 0) 

ggsave(glue("{save_dir}/generative_aRt{Sys.time() %>% str_replace_all(' ',  '_')}"),
       plot, height = height_in, width = width_in, units = "in", dpi = 700)
  