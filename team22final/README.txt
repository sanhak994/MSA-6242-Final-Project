1. DESCRIPTION - 
Our project is concerned with visualizing education data. We have a website hosting a predictor application, a choropleth map for visualizing scores over time, and a heatmap for viewing socioeconomic variables over state and year. 
The App directory contains files for the prediction app. The Data directory contains the scripts used to scrape and clean data for use in the app and in visualization. The Model directory contains JMP and Python files used for model creation. The SQLite directory contains files for the SQLite database that holds our data. The Vis directory contains the D3 files that produce the choropleth and heatmap visualizations.


2. INSTALLATION - 
Our application is hosted here: https://sanhak994.github.io/DVAeducationproject. Simply click this link to access our project; no outside packages need to be installed.  


3. EXECUTION -
To use the predictor application, you first need to install a few csv files from DropBox: Default_Data.csv, Custom_Data.csv, and (optionally) Data_Dictionary.csv. After loading the data files into the application, use the navigation tabs to choose models and predictors and to perform predictions.
To use the choropleth map, press the play button to see how test scores change over time or use the Prev and Next buttons to cycle through individual years. You can click on a state for a zoomed-in view and a breakdown of the importance of particular factors to academic success in that particular state. Click again to zoom back out. Zooming works best in Chrome. 
To use the heatmap, select a socioeconomic metric from the dropdown and observe the values of that metric for every state throughout the years.