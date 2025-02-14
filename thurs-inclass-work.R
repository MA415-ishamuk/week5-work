###
# notes from class
###

# don't forget to use omit.na for any r functions that may do a calculation on NA that 
# would give you a much more incorrect value (ex: mean) -> but you can't get rid of it 
# all the time if a large percentage of data is NA

###
# initial buoy project work from week 4 (edited down)
###

# load in libraries
library(data.table)
library(dplyr)
library(lubridate) # library that makes it easier to work with dates and times
library(ggplot2)
library(tibble)
library(readr)
library(esquisse)

# read in table
# between the file_root and tail is the year of the data that is wanted
# (this way you can easily loop through and read in each year's data)
file_root <- "https://www.ndbc.noaa.gov/view_text_file.php?filename=44013h" 
tail <- ".txt.gz&dir=data/historical/stdmet/"

# function to easily generate url to access buoy data per year 
# (connects file_root and tail via a particular year)
# update function to read in each of the years (not just one)
load_buoy_data <- function(year) {
  path <- paste0(file_root, year, tail)
  
  if (year < 2007) {
    header <- scan(path, what = 'character', nlines = 1)
    buoy <- read.table(path, fill = T, header = T, sep = "")
    buoy <- add_column(buoy, mm = NA, .after = "hh")
    buoy <- add_column(buoy, TIDE = NA, .after = "VIS")
  } else {
    header <- scan(path, what = 'character', nlines = 1)
    buoy <- fread(path, header = F, skip = 1, fill = T)
    
    setnames(buoy, header)
  }
}
all_data1 <- lapply(1985:2024, load_buoy_data)
combined_data1 <- rbindlist(all_data1, fill = T)

# more developed form of data pre processing
# combine year columns safely using coalesce
combined_data1 <- combined_data1 %>%
  mutate(
    YY = as.character(YY),
    '#YY' = as.character('#YY'),
    YYYY = as.character(YYYY)
  )

combined_data1 <- combined_data1 %>%
  mutate(YYYY = coalesce(YYYY, '#Y', YY))
# convert BAR and PRES to numeric
combined_data1 <- combined_data1 %>%
  mutate(BAR = coalesce(as.numeric(BAR), as.numeric(PRES)), 
         WD = coalesce(as.numeric(WD, as.numeric(WDIR)))) 
combined_data1 <- combined_data1 %>%
  select(-TIDE, -TIDE.1, -mm, -WDIR, -PRES, -'#YY', -YY)
combined_data1$datetime <- ymd_h(paste(combined_data1$YYYY, combined_data1$MM,
                                       combined_data1$DD, combined_data1$hh, sep = "-"))

combined_data1 <- combined_data1 %>%
  mutate(across(everything(), ~na_if(as.numeric(as.character(.)), 99) %>%
                  na_if(999) %>% naif(9999)))

# comment out old code that only read in one year of data
# path_1984 <- load_buoy_data("1984") # create the data path to access data from 1985
# #read in information as a table into R
# buoy_data_1984 <- read.table(path_1984, fill = T, header = T, sep = "") 

# convert time
buoy_data_1984[10, ] # prints out the tenth line of the buoy data 

date <- buoy_data_1984[10, 1:4] # columns 1-4 provide year, month, day, and hour needed for date

# getting the date into the right format to use within a lubridate function
date10 <- unlist(date) # simplifies something of type list to a vector
date10 <- as.character(date10)
date10 <- paste0(date10[1], "-", date10[2], "-", date10[3], "-", date10[4])
# using lubridate to manipulate into date format (year, month, date then hour)
format_date10 <- ymd_h(date10)
format_date10