#libraries needed
library(reshape2)
library(plyr)
library(tidyr)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
    download.file(fileURL, filename)
    }  
if (!file.exists("UCI HAR Dataset")) { 
        unzip(filename) 
    }
    
# Load activity labels + features

actLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
actLabels[,2] <- as.character(actLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Extract only the data on mean and standard deviation
features_Bit <- grep(".*mean.*|.*std.*", features[,2])
features_Bit.names <- features[features_Bit,2]
features_Bit.names = gsub('-mean', 'Mean', features_Bit.names)
features_Bit.names = gsub('-std', 'Std', features_Bit.names)
features_Bit.names <- gsub('[-()]', '', features_Bit.names)

#read the train and test data
train_set<-read.table("UCI HAR Dataset/train/X_train.txt",header=F)[features_Bit]
train_subjects<-read.table("UCI HAR Dataset/train/subject_train.txt")
train_labels<-read.table("UCI HAR Dataset/train/Y_train.txt")

test_set<-read.table("UCI HAR Dataset/test/X_test.txt",header=F)[features_Bit]
test_subjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test_labels<-read.table("UCI HAR Dataset/test/Y_test.txt")

train <- cbind(train_subjects, train_labels, train_set)
test <- cbind(test_subjects, test_labels, test_set)

total<- rbind(train, test)
colnames(total) <- c("subject", "activity", features_Bit.names)

# turn activities and subjects into factors
total$activity <- factor(total$activity, levels = actLabels[,1], labels = actLabels[,2])
total$subject <- as.factor(total$subject)

total.melted <- melt(total, id = c("subject", "activity"))
total.mean <- dcast(total.melted, subject + activity ~ variable, mean)

# Final tidy data output
write.table(total.mean, "tidydata.txt", row.names = FALSE, quote = FALSE)