##Download and unzip file
URL<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(URL, "./GettingAndCleaningData/UCIHARDataset.zip")
unzip("./GettingAndCleaningData/UCIHARDataset.zip", exdir = "./GettingAndCleaningData")

##Read activities and features
activity<-read.table("./UCI HAR Dataset/activity_labels.txt", header=FALSE)
activity[,2]<-as.character(activity[,2])
features<-read.table("./UCI HAR Dataset/features.txt", header=FALSE)
features[,2]<-as.character(features[,2])

##Extract the mean and standard deviation from features file
final_features<-grep(".*mean.*|.*std.*", features[,2])
feature_names<-features[final_features,2]
feature_names<-gsub("-mean", "mean", feature_names)
feature_names<-gsub("-std", "std", feature_names)
feature_names<-gsub("[-()]", "", feature_names)


##Read test files
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt", header=FALSE)
x_test<-read.table("./UCI HAR Dataset/test/X_test.txt", header=FALSE)[final_features]
y_test<-read.table("./UCI HAR Dataset/test/y_test.txt", header=FALSE)


##Bind columns to complete test data set
test_data<-cbind(subject_test, y_test, x_test)

##Read train files
subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
x_train<-read.table("./UCI HAR Dataset/train/X_train.txt", header= FALSE)[final_features]
y_train<-read.table("./UCI HAR Dataset/train/y_train.txt", header=FALSE)


##Bind columns to complete train data set
train_data<-cbind(subject_train, y_train, x_train)

##Merge data sets for train and test
merged_data<-rbind(train_data, test_data)

##Rename columns on merged data set
colnames(merged_data)<-c("subject", "activity", feature_names)

##Must turn activities and subjects into factors before melting and casting data
merged_data$activity <- factor(merged_data$activity, levels = activity[,1], labels = activity[,2])
merged_data$subject <- as.factor(merged_data$subject)

install.packages("reshape2")
library(reshape2)
data_melted <- melt(merged_data, id = c("subject", "activity"))
data_cast <- dcast(data_melted, subject + activity ~ variable, mean)

write.table(data_cast, "tidy.txt", row.names = FALSE, quote = FALSE)