library(tidyverse)

t_dif_data <- read_csv("data/GLB.Ts+dSST.csv", skip = 1, na = "***") %>% 
  select(year = Year, month.abb) %>% #month.adb selects all 12 months of the year
  pivot_longer(-year, names_to = "month", values_to = "t_dif") %>% 
  drop_na() %>% 
  mutate(month = factor(month, levels = month.abb))

#create a dataframe for the last December
# last_Dec <- t_dif_data %>%
#   filter(month == "Dec") %>%
#   mutate(year = year + 1,
#          month = "last_dec")
# 
#create a dataframe for the next January
next_Jan <- t_dif_data %>%
  filter(month == "Jan") %>%
  mutate(year = year - 1,
         month = "next_jan")

t_data <- bind_rows(t_dif_data, next_Jan) %>% 
  mutate(month = factor(month, levels = c(month.abb, "next_jan")),
         month_number = as.numeric(month)) #this will make last_dec =0 and next_jan = 1

#generating a label for our current year to add to the plot
annotation <- t_data %>%
  #filter(year == 2022) %>%
  slice_max(year) %>%
  slice_max(month_number)

#labeling the red lines
temp_lines <- tibble(x = 12,
                     y = c(1.5, 2.0),
                     labels = c("1.5\u00B0C", "2.0\u00B0C"))

#creating a data frame of the months and their positions
month_labels <- tibble(x = 1:12,
                       labels = month.abb,
                       y = 2.8)

t_data %>%
  ggplot(aes(x = month_number, y = t_dif, group = year, color = year)) +
  geom_col(data = month_labels, aes(x = x + .5, y = 2.4),
           fill = "black",
           width = 1,
           inherit.aes = F) +
  geom_col(data = month_labels, aes(x = x + .5, y = -2), #this second geom_col adds a new black circle on the inside of the spiral
           fill = "black",
           width = 1,
           inherit.aes = F) +
  geom_hline(yintercept = c(1.5, 2), color = "red") + #puts red line around plot
  geom_line() + #from here, our months are not in order but rather in alphabetical order. We will reorder this from line 7 above
  geom_point(data = annotation, aes(x = month_number, y = t_dif, color = year),
             inherit.aes = F, size = 3) +
  geom_label(data = temp_lines, aes(x = x, y = y, label = labels),
             color = "red",
             fill = "black",
             label.size = 0,
             inherit.aes = F) +
  geom_text(data = month_labels, aes(x = x, y = y, label = labels),
            color = "white",
            angle = seq(360 - 360/12, 0, length.out = 12), #creates a sequence that puts month labels tangential to spiral
            inherit.aes = F) + #we get a warning message after running this bc of missing values. If we increase the limits in scale_y_continuous, the warning disappears
  geom_text(aes(x = 1, y = -1.3, label = "2022"), #inserts label at center of spiral
            color = "blue", size = 6) + 
  scale_x_continuous(breaks = 1:12,
                     labels = month.abb,
                     expand = c(0,0),
                     sec.axis = dup_axis(name = NULL, labels = NULL)) + #adds top x-axis but removes labels
  scale_y_continuous(breaks = seq(-2, 2, .2),
                     limits = c(-2, 2.8), #increases the whole size at center of spiral
                     expand = c(0, -0.7),
                     sec.axis = dup_axis(name = NULL, labels = NULL)) + #adds right y-axis but removes labels
  scale_color_viridis_c(breaks = seq(1880, 2020, 20),
                        guide = "none") +
  #coord_cartesian(xlim = c(1,12)) +#helps to expand the x-axis labels
  coord_polar(start = 2*pi/12) + #recenters 1.5 and 2.0 oC on plot
  labs(x = NULL,
       y = NULL,
       title = "Global temperature change (1880-2022)") +
  theme(panel.background = element_rect(fill = "#444444", size = 1),#puts a white frame on plot area
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "#444444", color = "#444444"),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.title.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title = element_text(color = "white", size = 12),
        plot.title = element_text(color = "white", hjust = .5, size = 13)) 

ggsave("figures/global_climate_spiral_static.png", width = 8, height = 4)
