
# Shiny sandbox for 6242 Project


library(shiny)
library(shinyWidgets)
library(ggplot2)
library(randomForest)
library(gbm)
library(neuralnet)
library(rpart)

# TODO: require selecting at least one predictor for non-default models
# TODO: fix predictions for both default and custom models

# Shiny Application - P
ui <- fluidPage(
  
  navbarPage("Education Prediction Application",id="tabs",
             
             tabPanel("Data Loading",
                      
                      sidebarLayout(
                        
                        sidebarPanel(
                          fileInput("defaultFilePicker", "Choose data file for default models:", multiple = FALSE, accept = ".csv"),
                          actionButton("confirmDefaultButton","Confirm and View Default Data!"),
                          fileInput("customFilePicker", "Choose data file for custom models:", multiple = FALSE, accept = ".csv"),
                          actionButton("confirmCustomButton","Confirm and View Custom Data!")
                        ),
                        
                        mainPanel(
                          h2("Header of Default Data Table"),
                          div(uiOutput("defaultDataTableOutput"), style = "font-size:70%"),
                          h2("Header of Custom Data Table"),
                          div(uiOutput("customDataTableOutput"), style = "font-size:70%")
                        )
                        
                      )
 
             ),
             
             tabPanel("Data Dictionary",
                      
                      sidebarLayout(
                        
                        sidebarPanel(
                          fileInput("dataDictPicker", "Choose data dictionary file:", multiple = FALSE, accept = ".csv"),
                          actionButton("viewDictButton","View Data Dictionary!")
                        ),
                        
                        mainPanel(
                          h2("Data Dictionary"),
                          div(uiOutput("dataDictOutput"), style = "font-size:70%")
                        )
                        
                      )

             ),
             
             tabPanel("Model Building",

                      sidebarLayout(
                        
                        sidebarPanel(
                          uiOutput("initializeParams"),
                          uiOutput("initializeResponse"),
                          uiOutput("initializeModel"),
                          uiOutput("initializeBuildButton")
                        ),

                        mainPanel(
                          htmlOutput("initializeSummary"),
                          verbatimTextOutput("summary")
                        )


                      )
             ),
             
             tabPanel("Predicting",
                      
                      sidebarPanel(
                        uiOutput("paramValsLine"),
                        uiOutput("params"),
                        uiOutput("initializePredictionButton")
                      ),
                      
                      mainPanel(
                        uiOutput("modelLine"),
                        htmlOutput("modelPrediction")
                      ),

             )
             
             
  )
)

