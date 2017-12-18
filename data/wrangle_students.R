# Tuomas Tiihonen, 12.12.2017, This is a data wrangling script connected to
# my IODS final project.
#
# Original data from https://archive.ics.uci.edu/ml/datasets/Student+Performance
#

# Summon the dplyr package to gain access to mutate()

library(dplyr)

# Set the working directory

setwd('Z:/IODS-final/data/')

# Read the data with headers on first row
rawdata <- read.csv(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_2218/datasets/alc.txt"), header = TRUE)


# As we're going to utilise MCA in the analysis, we should make factors 
# out of the categorical variables that are currently integers.

rawdata$traveltime = factor(rawdata$traveltime)
rawdata$studytime = factor(rawdata$studytime)
rawdata$famrel = factor(rawdata$famrel)
rawdata$freetime = factor(rawdata$freetime)
rawdata$goout = factor(rawdata$goout)
rawdata$health = factor(rawdata$health)

# Having no failures is prevalent for the observations in the dataset, 
# and it is hence suitable to make a logical vector out of the variable, 
# with more than 0 failures resulting in TRUE. This, unlike an integer 
# variable, is also suitable for analysis through MCA.

rawdata = mutate(rawdata, failures = failures > 0) 

# To simplify the variables for mother's and father's education, both are
# divided into sub-secondary and at least secondary education, and 
# converted into factors.

rawdata = mutate(rawdata, Medu = ifelse(Medu > 2, "High", "Low"))
rawdata$Medu = factor(rawdata$Medu)
rawdata = mutate(rawdata, Fedu = ifelse(Fedu > 2, "High", "Low"))
rawdata$Fedu = factor(rawdata$Fedu)

# To ascertain the quartiles of the grade variable G3, we display it through
# the summary() function.

summary(rawdata$G3)

# Now that we've established the grade quartiles of the G3 variable 
# (1st: 0-8, 2nd: 9-11, 3rd: 12-14, 4th: 15-20), we can divide the 
# students into quartiles in a new variable, G3_quart. We do not replace 
# the values in the existing variable, as we may use them for 
# colour-coding the MCA plots.
#
# The function we use for dividing the quartiles is a nested mutate-ifelse.
# Not very elegant, but effective and _it works_.

rawdata = mutate(rawdata, 
                 G3_quart = ifelse(G3 %in% 9:11, "Q2",
                            ifelse(G3 %in% 11:14, "Q3",
                            ifelse(G3 %in% 14:20, "Q4", "Q1"))))

# We also convert the new variable into a factor.

rawdata$G3_quart = factor(rawdata$G3_quart)

# Finally we can drop the variables we don't need for the analysis.
# Alcohol use is already available through the logic vector "high_use" and
# grades are represented by the final grade "G3" and its quartiles in 
# "G3_quart".

rawdata <- subset(rawdata, select = -c(alc_use, G1, G2, Dalc, Walc))

# Now we can write the exploration-ready dataset into a new file.
#
# Through a fair bit of trial and error it became apparent that if the 
# IODS-standard csv-file is used, it doesn't retain the variable types
# we've so arduously perfected in this script. Well yes, how could it, 
# but that's beside the point and a good source for hanging my head in
# shame for not figuring it out at once - with all my experience it should
# be clear that there's no magical way a csv file can retain data types. 
#
# Because of that smidgin of information, we'll save the dataset as an 
# Rdata file, including all the variable metadata. This'll save us from
# having to factorise the categorical integers with more than two levels
# again.

save(rawdata, file = "wrangled_students.Rdata")
