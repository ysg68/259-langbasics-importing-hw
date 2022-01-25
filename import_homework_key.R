#PSYC 259 Homework 1 - Data Import
#For full credit, provide answers for at least 6/8 questions

#List names of students collaborating with (no more than 2): 

#GENERAL INFO 
#data_A contains 12 files of data. 
#Each file (6192_3.txt) notes the participant (6192) and block number (3)
#The header contains metadata about the session
#The remaining rows contain 4 columns, one for each of 20 trials:
#trial_number, speed_actual, speed_response, correct
#Speed actual was whether the figure on the screen was actually moving faster/slower
#Speed response was what the participant report
#Correct is whether their response matched the actual speed

### QUESTION 1 ------ 

# Load the readr package

# ANSWER
library(readr)

### QUESTION 2 ----- 

# Read in the data for 6191_1.txt and store it to a variable called ds1
# Ignore the header information, and just import the 20 trials
# Be sure to look at the format of the file to determine what read_* function to use
# And what arguments might be needed

# ds1 should look like this:

# # A tibble: 20 × 4
#  trial_num    speed_actual speed_response correct
#   <dbl>       <chr>        <chr>          <lgl>  
#     1          fas          slower         FALSE  
#     2          fas          faster         TRUE   
#     3          fas          faster         TRUE   
#     4          fas          slower         FALSE  
#     5          fas          faster         TRUE   
#     6          slo          slower         TRUE
# etc..

# A list of column names are provided to use:

col_names  <-  c("trial_num","speed_actual","speed_response","correct")

# ANSWER
ds1 <- read_tsv("data_A/6191_1.txt", skip = 7, col_names = col_names)


### QUESTION 3 ----- 

# For some reason, the trial numbers for this experiment should start at 100
# Create a new column in ds1 that takes trial_num and adds 100
# Then write the new data to a CSV file in the "data_cleaned" folder

# ANSWER
ds1$trial_num_100 <- ds1$trial_num + 100
write_csv(ds1, "data_cleaned/6191_1_cleaned.csv")

### QUESTION 4 ----- 

# Use list.files() to get a list of the full file names of everything in "data_A"
# Store it to a variable

# ANSWER
fnames <- list.files("data_A", full.names = TRUE)

### QUESTION 5 ----- 

# Read all of the files in data_A into a single tibble called ds

# ANSWER
ds <- read_tsv(fnames, skip = 7, col_names = col_names)

### QUESTION 6 -----

# Try creating the "add 100" to the trial number variable again
# There's an error! Take a look at 6191_5.txt to see why.
# Use the col_types argument to force trial number to be an integer "i"
# You might need to check ?read_tsv to see what options to use for the columns
# trial_num should be integer, speed_actual and speed_response should be character, and correct should be logical
# After fixing it, create the column to add 100 to the trial numbers (it should work now, but you'll see a warning)

# ANSWER
ds <- read_tsv(fnames, skip = 7, col_names = col_names, col_types = "iccl")
ds$trial_num_100 <- ds$trial_num + 100

# OTHER WAYS TO DO IT
#Make a better col_types string to save on typing
c_types <- c("i",rep("?",3))
ds <- read_tsv(fnames, skip = 7, col_names = col_names, 
               id = "filename", 
               col_types = c_types) 

#You can just set the type for any named column, it will guess the rest
ds <- read_tsv(fnames, skip = 7, col_names = col_names, 
               id = "filename", 
               col_types = list(trial_num = col_double())) 

#You can read the file to get the default guesses
ds <- read_tsv(fnames, skip = 7, col_names = col_names)
col_info <- spec(ds)
col_info$cols$trial_num <- col_double() #Then change the ones you want
ds <- read_tsv(fnames, skip = 7, col_names = col_names, col_types = col_info) #Then use that when reading

# FIX THE MISSING TRIAL NUMBER
library(tidyverse)
ds <- read_tsv(fnames, skip = 7, col_names = col_names, col_types = "iccl",id = "filename", )

ds <- ds %>% group_by(filename) %>% 
  mutate(lag_trial = lag(trial_num) + 1,
         lead_trial = lead(trial_num) - 1,
         trial_num = ifelse(is.na(trial_num), lag_trial, trial_num),
         trial_num = ifelse(is.na(trial_num), lead_trial, trial_num)) %>% 
  select(-lag_trial, - lead_trial) %>% 
  ungroup()
# This is a bit overboard but it's general and should fix any of them
# even if you have a missing trial 1 or trial 20 (but not missing multiple trials in a row)
# Similar logic could be used to detect incorrectly numbered trials that are out of sequence

# If I had one missing trial for a participants I would probably just hard code it:
ds <- read_tsv(fnames, skip = 7, col_names = col_names, col_types = "iccl") #RELOAD
ds <- ds %>% mutate(
  trial_num = ifelse(filename == "data_A/6191_5.txt" & is.na(trial_num), 20, trial_num)
) 


# Here's a neat way to do this I found online
ds <- read_tsv(fnames, skip = 7, col_names = col_names, col_types = "iccl") #RELOAD
ds$trial_num <- na_if(ds$trial_num, 3) # Let's create even more problems
ds$trial_num <- na_if(ds$trial_num, 4) # Let's create even more problems
ds$trial_num <- na_if(ds$trial_num, 5) # Let's create even more problems

#This one works even on chunks of missing data
ds <- ds %>% mutate(tmp = cumsum(!is.na(trial_num))) %>% 
  group_by(tmp) %>%
  mutate(trial_num = trial_num[1] + 0:(length(trial_num)-1)) %>%
  ungroup() %>%
  select(-tmp)

### QUESTION 7 -----

# Now that the column type problem is fixed, take a look at ds
# We're missing some important information (which participant/block each set of trials comes from)
# Read the help file for read_tsv to use the "id" argument to capture that information in the file
# Re-import the data so that filename becomes a column

# ANSWER
ds <- read_tsv(fnames, skip = 7, col_names = col_names, col_types = "iccl", id = "filename")

# How to get more useful info out of file name?
library(tidyr)
ds <- ds %>% extract(filename, into = c("id","session"), "(\\d{4})_(\\d{1})") 
#Extract takes a character variable, names of where to put the extracted data,
# and then a regular expression saying what pattern to look for.
# each part in parentheses is one variable to extract
# \\d{4} means 4 digits, \\d{1} means 1 digit

# Or use "separate", which breaks everything by any delimiter (or a custom one)
# data_A/6191_1.txt will turn into:
# data   A   6191   1   txt
# if we only want to keep 6191 and 1, we can put NAs for the rest
ds <- ds %>% separate(filename, into = c(NA, NA, "id", "session", NA))
                      
### QUESTION 8 -----

# Your PI emailed you an Excel file with the list of participant info 
# Install the readxl package, load it, and use it to read in the .xlsx data in data_B
# There are two sheets of data -- import each one into a new tibble

# ANSWER

install.packages("readxl")
library(readxl)
ppt_info <- read_xlsx("data_B/participant_info.xlsx")
test_dates <- read_xlsx("data_B/participant_info.xlsx", col_names = c("participant", "test_date"), sheet = 2)

