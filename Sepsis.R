#dataset = read.csv("p000001.psv", sep = "|", header = TRUE, stringsAsFactors = FALSE)
#dataset= dataset[-1,]
#for (i in c(2:500)) {
# noofzeros = 6- nchar(i)
#s2=paste(replicate(noofzeros,"0"),collapse = "")
#s1="p"
#s3=".psv"
#s1=paste(s1,s2,as.character(i),s3,sep="")
#datasets_t=read.csv(s1, sep = "|", header = TRUE, stringsAsFactors = FALSE)
#datasets_t=datasets_t[-1,]
#dataset=rbind2(dataset,datasets_t)
#}
#test_set=dataset
#write.csv(dataset,file="compiled_data.csv")  
dataset=read.csv("compiled_data.csv")
#install.packages("mice")
#dataset=dataset[0:100,]
dataset=dataset[-1,]
glimpse(dataset)
summary(dataset)
str(dataset)
for (i in c(1:ncol(dataset))) {
  
  dataset[,i] <- as.numeric(as.character(dataset[,i]))
}
library(mice)
md.pattern(dataset)
imputed_Data <- mice(dataset, m=1, maxit = 1, method = 'pmm',seed='500')
dataset <- complete(imputed_Data,1)
write.csv(dataset,"compiled_data.csv")

library(caTools)
set.seed(123)
split = sample.split(dataset$SepsisLabel, SplitRatio = 8/10 )
training_set=subset(dataset,split==TRUE)
test_set=subset(dataset,split==FALSE)

############################MULTIPLE REGRESSION###################

ML<-lm(formula= SepsisLabel~HR+O2Sat+Temp+SBP+MAP+DBP+Resp+BaseExcess+HCO3+FiO2+pH+PaCO2+SaO2+AST+BUN+
         Alkalinephos +Calcium +Chloride +Creatinine + Glucose +Lactate +Magnesium +Phosphate+
         Potassium +Bilirubin_total +  Hct  +Hgb  + PTT+  WBC +Fibrinogen+ Platelets  + Age+ Gender+ Unit1
       +HospAdmTime+ICULOS
       ,data=training_set)

pred_mul_reg=predict(ML,test_set[,-41])
pred_mul_reg<- ifelse(pred_mul_reg>0.5,1,0)

confmatrix<- table(pred_mul_reg,test_set[,41])

accuracy_mulreg<- (confmatrix[1,1])/length(test_set[,41])
accuracy_mulreg
summary(ML)                 ##### Adjusted R squared is 0.0801
plot(ML)
######BACKWARD ELIMINATION (SETTING THE SIGNIFICANCE LEVEL AS 0.05)###################

ML<-lm(formula= SepsisLabel~HR+O2Sat+Temp+MAP+Resp+FiO2+
         Alkalinephos  +Creatinine  +Phosphate+
         Fibrinogen+ Platelets  + Age+ Gender+ Unit1 +ICULOS
       ,data=training_set)

pred_mul_reg=predict(ML,test_set[,-41])
pred_mul_reg<- ifelse(pred_mul_reg>0.5,1,0)

confmatrix<- table(pred_mul_reg,test_set[,41])

accuracy_mulreg<- (confmatrix[1,1])/length(test_set[,41])
accuracy_mulreg
summary(ML)                 ##### Adjusted R squared is 0.0801
plot(ML)
######final accuracy of Multiple Regression is 0.97785 #####################

#install.packages('xgboost')
library(xgboost)
classifier_xgb=xgboost(data=as.matrix(training_set[,-41]),label=training_set$SepsisLabel,nrounds=300)
y_pred=predict(classifier_xgb,newdata=as.matrix(test_set[,-41]))

y_pred0 = (y_pred <=0.3)
y_pred1=(y_pred>=0.7)
final_pred<- ifelse(y_pred<0.5,0,1)
final_table=table(final_pred,test_set[,41])
total_correct_predicts=final_table[1,1]+final_table[2,2]
accuracy=total_correct_predicts/nrow(test_set)

ggplot()+geom_point(aes(x=index(test_set[,41]),y=test_set[,41]),color="green")
+geom_point(aes(x=index(final_pred),y=final_pred),color="red")+xlab("index")+ylab("SespsisLabel")
+ggtitle("Original(Green) VS Predicted(Red)")


############final accuracy of XGBoost algo is 0.9855################



###############       PLOTS OF SOME XGBOOST MODELS        #################

#plot_tree(classifier)
library(data.tree)
install.packages(data.tree)
xgb.plot.tree(model = classifier,trees=0,show_node_id=TRUE)
index=c(1:nrow(model))

model=data.frame(index,model)
ggplot(model,aes(x=index,y=c(y_pred),col=test_set$SepsisLabel)) +geom_point()

plot( model$index, model$test_set.SepsisLabel, type="p", col="red" )
par(new=TRUE)
plot( model$index,model$y_pred, type="p", col="green" )

plot(dataset$SepsisLabel,dataset$WBC,type="p")

vals=c(table(y_pred0)[1],table(dataset[1:80000,]$SepsisLabel)[2],table(y_pred0)[2],table(dataset[1:80000,]$SepsisLabel)[1])
names(vals)[1]<- paste("Sepsis Present")
names(vals)[2]<- paste("Predicted Sepsis Present")
names(vals)[3]<- paste("Sepsis Not Present")
names(vals)[4]<- paste("Predicted Sepsis Not Present")
barplot(vals)




##################### Artificial Neutral Networks  ###################
library(h2o)
h2o.init(nthreads=-1)
classifier=h2o.deeplearning(y= 'SepsisLabel',
                            training_frame= as.h2o(training_set),
                            activation='Rectifier',
                            hidden=c(6,6),
                            epochs=100,
                            train_samples_per_iteration=-2)
ANN_predict= predict(classifier,type='response', newdata = test_set[,-41])
y_pred_ann=ifelse(ANN_predict>0.5,1,0)
x_Valzz<- y_pred_ann$C1
conf_matrix_ann<- table(as.vector(x_Valzz),test_set[,41])
total_correct_predicts=conf_matrix_ann[1,1]+conf_matrix_ann[2,2]
accuracy=total_correct_predicts/nrow(test_set)
plot(classifier,timestep = "duration", metric = "rmse")


############final accuracy of ANN algo is 0.97905   ################


print("By far the best model with highest accuracy is XGBoost" )



find_result<- function(){
  training_set=read.csv("compiled_data.csv")
  print(training_set)
  training_set=training_set[,2:43]
  test_set=read.csv("compiled_data2.csv")
  test_set<- test_set[1:1000,]
  print(test_set)
  classifier_xgb=xgboost(data=as.matrix(training_set[,-42]),label=training_set$SepsisLabel,nrounds=300)
  y_pred=predict(classifier_xgb,newdata=as.matrix(test_set[,-42]))
  final_pred<- ifelse(y_pred<0.5,0,1)
  final_table=table(final_pred,test_set[,42])
  total_correct_predicts=final_table[1,1]+final_table[2,2]
  accuracy=total_correct_predicts/nrow(test_set)
  write.csv(final_pred,"final_output.csv")
}