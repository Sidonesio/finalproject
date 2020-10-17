
rm(list=ls()) # clean memory
library(dplyr) # load package

fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileURL, destfile = "data.zip") # download file
unzip("data.zip") # unzip file

# read all txt files into R
features <- read.table("UCI HAR Dataset/features.txt", 
                       col.names = c("n","functions"))
activities <- read.table("UCI HAR Dataset/activity_labels.txt", 
                         col.names = c("code", "activity"))
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", 
                           col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", 
                     col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "code")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", 
                            col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", 
                      col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "code")

# merge training and test sets to create one data set

X <- rbind(x_train, x_test) # bind rows from training and test measurements
Y <- rbind(y_train, y_test) # bind rows from training and test activities
Subject <- rbind(subject_train, subject_test) # bind rows from training and test subjects
merged <- cbind(Subject, Y, X) # bind columns from 3 above dataframes

# extract only the measurements on the mean and standard deviation 
# for each measurement
extract <- merged %>% 
  select(subject, code, contains("mean"), contains("std"))

# use descriptive activity names to name the activities in the data set
extract$code <- activities[extract$code, 2]

# appropriately label the data set with descriptive variable names
names(extract)[2] <- "activity"
names(extract) <- gsub("Acc", "Accelerometer", names(extract))
names(extract) <- gsub("Gyro", "Gyroscope", names(extract))
names(extract) <- gsub("BodyBody", "Body", names(extract))
names(extract) <- gsub("Mag", "Magnitude", names(extract))
names(extract) <- gsub("^t", "Time", names(extract))
names(extract) <- gsub("^f", "Frequency", names(extract))
names(extract) <- gsub("tBody", "TimeBody", names(extract))
names(extract) <- gsub("-mean()", "Mean", names(extract), ignore.case = TRUE)
names(extract) <- gsub("-std()", "STD", names(extract), ignore.case = TRUE)
names(extract) <- gsub("-freq()", "Frequency", names(extract), ignore.case = TRUE)
names(extract) <- gsub("angle", "Angle", names(extract))
names(extract) <- gsub("gravity", "Gravity", names(extract))

# from the data set "extract"
# creates a second and independent tidy data set 
# with the average of each variable 
# for each activity 
# and each subject
final <- extract %>%
  group_by(subject, activity) %>%
  summarise_all(funs(mean))
write.table(final, "final.txt", row.name=FALSE)