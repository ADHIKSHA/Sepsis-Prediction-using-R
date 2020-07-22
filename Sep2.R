  setwd('C:\\xampp\\htdocs\\PA')
  library(xgboost)
  training_set=read.csv("compiled_data.csv")
  training_set=training_set
  test_set=read.csv("testing.csv")
  test_set<- test_set
  
  classifier_xgb=xgboost(data=as.matrix(training_set[,-41]),label=as.matrix(training_set[,41]),nrounds=300)
  y_pred=predict(classifier_xgb,newdata=as.matrix(test_set[,-41]))
  final_pred<- ifelse(y_pred<0.5,0,1)
  final_table=table(final_pred,test_set[,41])
  total_correct_predicts=max(final_pred)
  write(total_correct_predicts,"final_output.txt",append = FALSE)
