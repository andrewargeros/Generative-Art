# Generative Art

This code will generate a city-like plot using random points and branching simulations. The code has multiple parameters that can be changed to optimize the code for you. Additionally, since the plots rely on randomness, you'll never get the same plot twice! *...unless you use `set.seed()`.*

## Parameters

|Name        | Variable   | Description                            | Default    |
|------------|------------|----------------------------------------|------------|
|Iterations  | `n`        | How many lines should be drawn?        | 10,000     |
|Neighborhood| `r`        | What is the radius of the neighborhood?| 75         |
|Width       | `width_in` | How wide should the plot be in inches? | 11         |
|Height      | `height_id`| How tall should the plot be in inches? | 8.5        |
|Angle       | `delta`    | What angle should branches favor?      | `2*pi/180` |
|Branching   | `p_branch` | How often should branches happen?      | 0.1        |
|Directory   | `save_dir` | Where should the plot save?            | C:/RScripts|

#### Additional Customization

Additional **ggplot** customizations can be added to the `plot` section of the code. Currently, the code is set up to use the `Viridis` color scheme. Obviously, this, and the plot background color can be changed.

```r
points %>%
  make_lines(edges, n, r, delta, width_in, height_in, p_branch, initial_pts) %>%
  ggplot() +
  aes(x, y, xend = xend, yend = yend, size = -level, color = level) +
  geom_segment(lineend = "round", show.legend = F) +
  scale_color_viridis_c(begin = 0.05, end = 0.85) + # change the color if you want
  xlim(0, width_in*1000) +
  ylim(0, height_in*1000) +
  coord_equal() +
  scale_size_continuous(range = c(0.5, 0.5)) +
  theme_blankcanvas(bg_col = "#d2e7f5", margin_cm = 0) +
  ggsave(glue("{save_dir}/generative_aRt{Sys.time() %>% str_replace_all(' ',  '_')}"))
```

## Example:

![](https://github.com/andrewargeros/generative-art/blob/main/Example/wall_art_color2.png?raw=true)
