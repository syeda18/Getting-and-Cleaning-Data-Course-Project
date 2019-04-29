#run_analysis.R

#1. Install library
library(reshape2)


#2. Get dataset from web
rawDataDir <- "./rawData"
rawDataUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
rawDataFilename <- "rawData.zip"
rawDataDFn <- paste(rawDataDir, "/", "rawData.zip", sep = "")
dataDir <- "./data"

if (!file.exists(rawDataDir)) {
  dir.create(rawDataDir)
  download.file(url = rawDataUrl, destfile = rawDataDFn)
}
if (!file.exists(dataDir)) {
  dir.create(dataDir)
  unzip(zipfile = rawDataDFn, exdir = dataDir)
}


#3. Merge {train, test} dataset
# data: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# train data
a_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/A_train.txt"))
b_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/B_train.txt"))
c_train <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/train/subject_train.txt"))

# test data
a_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/A_test.txt"))
b_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/B_test.txt"))
c_test <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/test/subject_test.txt"))

# merge data using the bind function
a_data <- rbind(a_train, a_test)
b_data <- rbind(b_train, b_test)
c_data <- rbind(c_train, c_test)


#4. Load feature & activity info
# feature info
feature <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/features.txt"))

# activity labels
a_label <- read.table(paste(sep = "", dataDir, "/UCI HAR Dataset/activity_labels.txt"))
a_label[,2] <- as.character(a_label[,2])

# extract feature cols & names named 'mean, std'
selectedCols <- grep("-(mean|std).*", as.character(feature[,2]))
selectedColNames <- feature[selectedCols, 2]
selectedColNames <- gsub("-mean", "Mean", selectedColNames)
selectedColNames <- gsub("-std", "Std", selectedColNames)
selectedColNames <- gsub("[-()]", "", selectedColNames)


#5. extract data by cols & using descriptive name
a_data <- a_data[selectedCols]
allData <- cbind(c_data, b_data, a_data)
colnames(allData) <- c("Subject", "Activity", selectedColNames)

allData$Activity <- factor(allData$Activity, levels = x_label[,1], labels = y_label[,2])
allData$Subject <- as.factor(allData$Subject)


#6. generate tidy data set
meltedData <- melt(allData, id = c("Subject", "Activity"))
tidyData <- dcast(meltedData, Subject + Activity ~ variable, mean)

write.table(tidyData, "./tidy_data.txt", row.names = FALSE, quote = FALSE)
