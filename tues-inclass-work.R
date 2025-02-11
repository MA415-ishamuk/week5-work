###
# notes from class
###

# data frames are a type of list (tibbles in tidyverse are similar to data frames)

# search for information about different r packages through cran

# in penguin dat aset want to find the max and min value - use range(penguins$body_mass_g)
# but doing this as such will give NA NA bc there are NA values in the data set so before
# calling one must remove the NAs by doing range(penguins$body_mass_g, na.rm = T)

# geom_smooth() will always default to "loess" if a method is not otherwise specified 

###
# ggplot2 demo
###

# load in necessary libraries
library(tidyverse)
library(palmerpenguins)
library(ggthemes)

# load the penguins data set into r
data("penguins")

# example data processing to figure out x and y range for plotted variables
range(penguins$body_mass_g, na.rm = T)
range(penguins$flipper_length_mm, na.rm = T)

# define the ggplot to visualize the penguin data
# in ggplot mapping asks for information regarding x and y 
# geom_point() says to plot the data in the form of a scatter plot
# geom_smooth(method = "lm") will produce a straight linear regression on the plot
# every geom is able to have its own mapping
ggplot(data = penguins, mapping = aes(x = flipper_length_mm, y = body_mass_g)) +
  geom_point(mapping = aes(color = species, shape = island), size = 2) +
  geom_smooth(method = "lm") + scale_color_colorblind()
