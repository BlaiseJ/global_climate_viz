library(tidyverse)
library(R.utils) #for unzippng gz files
library(ncdf4) #for working with netCDF files in R
library(data.table) #converting arrays to tibbles
library(lubridate)
library(ggridges)


url <- "https://data.giss.nasa.gov/pub/gistemp/gistemp250_GHCNv4.nc.gz"

download.file(url, destfile = "gistemp250_GHCNv4.nc.gz")#downloads our file from link address
gunzip("gistemp250_GHCNv4.nc.gz")

 #reading the netCDF file contents
nc_data <- nc_open('gistemp250_GHCNv4.nc')

# Save the print(nc) dump to a text file
{
  sink('gistemp250_GHCNv4.txt') #sink helps to create a file, print and sink to close
  print(nc_data)
  sink()
}


lon <- ncvar_get(nc_data, "lon") #data array from -179 to 179 by 2 degree increments
lat <- ncvar_get(nc_data, "lat", verbose = F) #goes from -89 to 89 by 2 degree increments
t <- ncvar_get(nc_data, "time") #time since the 1800

head(lon) # look at the first few entries in the longitude vector


t_anomaly.array <- ncvar_get(nc_data, "tempanomaly") # store the data in a 3-dimensional array. tempanomaly is in the gistemp250_GHCNv4.txt file
dim(t_anomaly.array)

#addressing missing data
fillvalue <- ncatt_get(nc_data, "tempanomaly", "_FillValue")
t_anomaly.array[t_anomaly.array == fillvalue$value] <- NA #converts all missing values to NAs


t_data <- as.data.table(t_anomaly.array) %>%  #we get a long dataframe with over 8 million rows. this command already removes all NA values
  as_tibble() %>% #converts to a tibble
  select(long = V1, lati = V2, time = V3, t_dif = value) %>% 
  mutate(long = lon[long], 
         lati = lat[lati],
         time = t[time] + as.Date("1800-01-01"),
         year = year(time)) %>%  #tail()#1800-01-01 comes from the gistemp250_GHCNv4.txt file
  group_by(year, long, lati) %>% 
  summarise(t_dif = mean(t_dif), .groups = "drop") %>% 
  #count(year) %>% 
  #ggplot(aes(x = year , y = n)) + 
  #geom_line()
  filter(year >= 1950) %>% 
  group_by(year) %>% #these next two lines will help change the fill below from year to t_avr
  mutate(t_avr = mean(t_dif))

t_data %>% 
  filter(year %in% c(1970, 1980, 1990, 2000, 2010, 2020)) %>% 
  ggplot(aes(x = t_dif, y = factor(year, levels = seq(2020, 1970, -1)), #reverts the order from 2020 to 1970 to 1970 to 2020
             fill = t_avr)) +
  geom_density_ridges(bandwidth = .5, scale = 2.5,#scale=2.5 increases overlap between the graphs
                      size = .2, color = "white") + #changes thickness of histogram margin line as well as the color from black to white
  scale_fill_gradient2(low = "darkblue", mid = "white", high = "darkred", 
                       midpoint = 0, guide = "none")+ #guide="none removes legend
  coord_cartesian(xlim = c(-5, 5)) +#changes the x scale to run from -5 to 5
  scale_x_continuous(breaks = seq(-3, 6, 2)) +
  #scale_y_discrete(breaks = 1970, 2020, 10) + #use this if you did not filter as above
  labs(y = NULL,
       x = "Temperature anomaly (\u00B0 C)",
       title = "Land Temperature Anomaly Distribution") +
  theme(text = element_text(color = "white"),
        panel.background = element_rect(fill = "black"),
        plot.background = element_rect(fill = "black"),
        panel.grid = element_blank(),
        axis.text = element_text(colour = "white"),
        axis.ticks = element_line(colour = "white"),
        axis.ticks.y = element_blank(),
        axis.line.x = element_line(colour = "white"),
        axis.line.y = element_blank())

ggsave("figures/temperature_distrib.png", width = 6, height = 5)

nc_close(nc_data) #closes the connection to our nc_data
unlink("gistemp250_GHCNv4.nc") #unlinks this file from our project directory
unlink("gistemp250_GHCNv4.txt")
