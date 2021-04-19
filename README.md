# Sepsis-Prediction-using-R
**R** script with PHP backend for Prediction of Sepsis. The R script is intergrated with PHP backend using EXEC command. You can also link it using API calls if you deploy this app to a R notebook. (To add as an API check my Link-PHP-to-Python repository)

## Dataset
Download the dataset from https://physionet.org/content/challenge-2019/1.0.0/

## Details
This R script uses XGboost for early and easier prediction of sepsis. Also integrates the R script with PHP and displays the final result. We use multiple R libraries for Data visualization and prediction. This app gives us a very high accuracy due to mean error correction every cycle.

## Functionalities
1. Visualization of large data.
2. Faster and Robust Training models with > 93% accuracy.
3. Integration with PHP scripts of the data.

## Usage
```
> Run the PHP server (Xampp server)
> Open the php file > **show.php**
> And this will run the file and give the output. Add your data in **testing.csv** file to check the output.
> The final output can be found in **final_output.csv** file.
```

## Disclaimer
If you just want to see how the models have been selected and more visulalization , you can open the Sepsis.R file and run the code to get proper model and dataset information. Without using the PHP frontend.
