# obtaining climate data from nasa
- link to data : https://data.giss.nasa.gov/gistemp/
- navigate to Datasets > GISTEMP Surface Temperature > Table of global and hemispheric monthly means and zonal annual means > global-mean monthly, seasonal and annual means
- click on .csv to download and copy to data/ directory
- right click on the .csv file to copy link address: https://data.giss.nasa.gov/gistemp/tabledata_v4/GLB.Ts+dSST.csv

#next dataset
- from same link as above
- navigate to
Compressed NetCDF Files (regular 2°×2° grid) > Surface air temperature (no ocean data), 250km smoothing (9MB)
- it is a .gz file
- right click and copy link address and paste in R script
https://data.giss.nasa.gov/pub/gistemp/gistemp250_GHCNv4.nc.gz
- the file is 10MB. this is larger than something to mess with in github
- add the file in gitignore using any part of the filename so it can be ignored during commit
e.g. i used gistemp*
- the star indicates that anything beginning with gistemp should be ignored

- to get the appropriate date format from the time column, we use 1800-01-01 from the gistemp250_GHCNv4.txt file which takes each of the times and adds to 1800-01-01 to create a true date for us

- when we pipe the statements below into ggplot, we get a plot showing a steady increase in data. but there is a sharp increase before the 1960 mark. we might want to select data begin from this point going forward

count(year) %>% 
  ggplot(aes(x = year , y = n)) + 
  geom_line()
  
- you could remove the filter statement below from the ggplot code if you want to have a plot of the entire dataset

filter(year %in% c(1970, 1980, 1990, 2000, 2010, 2020))

-we used scale_y_discrete because we turned the year to a factor

