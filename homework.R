#PSYC 259 Homework 1 - Data Import
#For full credit, provide answers for at least 6/8 questions (8/8)

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
ds1 <- read_delim("data_A/6191_1.txt", skip = 7, col_names = col_names)

#MComment: Looks good, though note you can also use read_tsv (with the same commands)
ds1 <- read_tsv("data_A/6191_1.txt", skip = 7, col_names = col_names)


### QUESTION 3 ----- 

# For some reason, the trial numbers for this experiment should start at 100
# Create a new column in ds1 that takes trial_num and adds 100
# Then write the new data to a CSV file in the "data_cleaned" folder

# ANSWER
ds1$trial_mod <- ds1$trial_num + 100
write_csv(ds1, "data_B/6191_1.csv") # There is no 'data_cleaned' folder so was it 'data_B'?

#MComment: Technically you needed to make a new folder, either on your computer or using dir.create

### QUESTION 4 ----- 

# Use list.files() to get a list of the full file names of everything in "data_A"
# Store it to a variable

# ANSWER
ds_all <- list.files("data_A", all.files = FALSE, full.names = TRUE)
ds_all

#MComment: You don't need the all.files command in this instance (just as a headsup)

### QUESTION 5 ----- 

# Read all of the files in data_A into a single tibble called ds

# ANSWER
ds <- read_delim(ds_all, skip = 7, col_names = col_names)


### QUESTION 6 -----

# Try creating the "add 100" to the trial number variable again
# There's an error! Take a look at 6191_5.txt to see why.
# Use the col_types argument to force trial number to be an integer "i"
# You might need to check ?read_tsv to see what options to use for the columns
# trial_num should be integer, speed_actual and speed_response should be character, and correct should be logical
# After fixing it, create the column to add 100 to the trial numbers 
# (It should work now, but you'll see a warning because of the erroneous data point)

# ANSWER

ds$trial_num[ds$trial_num == 'ten'] <- 10
ds$trial_num <- as.integer(ds$trial_num)

#Mcomment: you can also change to an interger with the col_types command
ds <- read_tsv(ds_all, skip = 7, col_names = col_names, col_types = "iccl")


### QUESTION 7 -----

# Now that the column type problem is fixed, take a look at ds
# We're missing some important information (which participant/block each set of trials comes from)
# Read the help file for read_tsv to use the "id" argument to capture that information in the file
# Re-import the data so that filename becomes a column

# ANSWER

ds_re <- read_tsv(ds_all, skip = 7, col_names = col_names, id = "dataA")

ds_re$trial_num[ds_re$trial_num == 'ten'] <- 10
ds_re$trial_num <- as.integer(ds_re$trial_num)

#Mcomment: Note from the key - 

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

library(readxl)
participant <- read_excel("data_B/participant_info.xlsx", sheet = 1)

colnames <- c("id", "date")
test_date <- read_excel("data_B/participant_info.xlsx", sheet = 2, col_names = colnames)
