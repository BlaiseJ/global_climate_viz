library(tidyverse)

read_csv("data/GLB.Ts+dSST.csv", skip = 1, na = "***") %>% #skip=1 skips the first line, na="***" replaces every 3 star with an NA
  select(year = Year, t_dif = `J-D`) %>%  #select columns of interest
  ggplot(aes(x = year, y = t_dif)) + #temp differences across years
  geom_line(aes(color = "1"), size = .5, show.legend = F) +
  geom_point(fill = "white", aes(color = "1"), shape = 21, show.legend = T) + #show.legend=F removes circle around legend lines
  geom_smooth(se = F, aes(color = "2"), size = .5, span = .10, show.legend = F) +#generates a smooth line across the plotted data, span changes the wiggly nature of the line
  scale_x_continuous(breaks = seq(1880, 2023, 20), expand = c(0,0)) + #from 1880 to 2023 in increments of 20 yrs
  scale_y_continuous(limits = c(-.5, 1.5), expand = c(0,0)) + #expand removes gaps between axes and plot
  scale_color_manual(name = NULL,
                     breaks = c(1, 2),
                     values = c("gray", "black"),
                     labels = c("Annual mean", "Loess smoothing"),
                     guide = guide_legend(override.aes = list(shape = 15, size = 4)))+ #this line changes legend shapes from circle to square
  labs(x = "YEAR",
       y = "Temperatureanomaly (C)",
       title = "GLOBAL LAND-OCEAN TEMPERATURE INDEX",
       subtitle = "Data source: NASA's Goddard Institute for Space Studies (GISS). \nCredit: NASA/GISS") +
  theme_light() + #gives a white background with grid lines
  theme(axis.ticks = element_blank(), #removes ticks on both axes
        plot.title.position = "plot", #left justifies the title
        plot.title = element_text(margin = margin(b = 10), color = "red", face = "bold"),
        plot.subtitle = element_text(size = 9, margin = margin(b = 10)),
        legend.position = c(.17, .9),
        legend.title = element_text(size = 0),
        legend.key.height = unit(12, "pt"),
        legend.margin = margin(0,0,0,0),
        legend.background = element_blank()) 

ggsave("figures/temp_index.png", width = 6, height = 5)