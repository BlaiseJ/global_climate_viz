library(tidyverse)

t_dif_data <- read_csv("data/GLB.Ts+dSST.csv", skip = 1, na = "***") %>% 
  select(year = Year, month.abb) %>% #month.adb selects all 12 months of the year
  pivot_longer(-year, names_to = "month", values_to = "t_dif") %>% 
  drop_na() %>% 
  mutate(month = factor(month, levels = month.abb))

#create a dataframe for the last December
last_Dec <- t_dif_data %>% 
  filter(month == "Dec") %>% 
  mutate(year = year + 1,
         month = "last_dec")

#create a dataframe for the next January
next_Jan <- t_dif_data %>% 
  filter(month == "Jan") %>% 
  mutate(year = year - 1,
         month = "next_jan")

t_data <- bind_rows(last_Dec, t_dif_data, next_Jan) %>% 
  mutate(month = factor(month, levels = c("last_dec", month.abb, "next_jan")),
         month_number = as.numeric(month) - 1, #this will make last_dec =0 and next_jan = 1
         this_year = year == 2022)

#generating a label for our current year to add to the plot
annotation <- t_data %>% 
  #filter(year == 2022) %>% 
  slice_max(year) %>% 
  slice_max(month_number)

t_data %>%
  ggplot(aes(x = month_number, y = t_dif, group = year, 
             color = year, size = this_year)) +
  geom_hline(yintercept = 0, color = "white") +
  geom_line() + #from here, our months are not in order but rather in alphabetical order. We will reorder this from line 7 above
  geom_text(data = annotation, 
            aes(x = month_number, 
                y = t_dif, 
                label = year, 
                color = year), 
            inherit.aes = F,
            hjust = 0, size = 4,
            nudge_x = .15,
            fontface = "bold") + #all of this code block is annotating the line for 2022
  scale_x_continuous(breaks = 1:12,
                     labels = month.abb, 
                     sec.axis = dup_axis(name = NULL, labels = NULL)) + #adds top x-axis but removes labels
  scale_y_continuous(breaks = seq(-2, 2, .2),
                     sec.axis = dup_axis(name = NULL, labels = NULL)) + #adds right y-axis but removes labels
  scale_size_manual(breaks = c(F, T),
                    values = c(.25, 1), guide = "none") +
  scale_color_viridis_c(breaks = seq(1880, 2020, 20),
                        guide = guide_colorbar(frame.colour = "white",
                                               frame.linewidth = 1)) +#line adds white border around legend
  coord_cartesian(xlim = c(1,12)) +#helps to expand the x-axis labels
  labs(x = NULL,
       y = "Temperature change since pre-industrial time [\u00B0C]",
       title = "Global temperature change since 1880, by month") +
  theme(panel.background = element_rect(fill = "black", color = "white", size = 1),#puts a white frame on plot area
        panel.grid = element_blank(),
        plot.background = element_rect(fill = "#444444"),
        axis.text = element_text(colour = "white", size = 12),
        axis.ticks = element_line(color = "white"),
        axis.ticks.length = unit(-5, "pt"), #-5 helps to move tick marks inward
        axis.title = element_text(color = "white", size = 12),
        plot.title = element_text(color = "white", hjust = .5, size = 13),
        legend.title = element_blank(),
        legend.background = element_rect(fill = NA),#fill=NA removes the legend background color
        legend.text = element_text(color = "white"),
        legend.key.height = unit(45, "pt")) 

ggsave("figures/temp_lines.png", width = 8, height = 4)
