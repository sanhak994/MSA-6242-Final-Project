# Clear environment
rm(list = ls())

library(shiny)
library(ggplot2)
library(randomForest)

dat <- read.csv("Prediction_inflation_adjusted.csv", header=TRUE)
dat.df <- as.data.frame(dat)

model.rf <- randomForest(AVG_ALL_SCORES~TOTAL_REVENUE+TOTAL_EXPENDITURE+ALL_STUDENT_TEACHER_RATIO,data=dat.df)

summary(model.rf)
model.rf
tail(model.rf$rsq, n=1)
states <- unique(dat.df$STATE)

new.dat.df <- as.data.frame(cbind(mean(dat.df$TOTAL_REVENUE),mean(dat.df$TOTAL_EXPENDITURE),mean(dat.df$ALL_STUDENT_TEACHER_RATIO)))
colnames(new.dat.df) <- c("TOTAL_REVENUE","TOTAL_EXPENDITURE","ALL_STUDENT_TEACHER_RATIO")

pred <- predict(model.rf,new.dat.df)
pred
years <- unique(dat.df$YEAR)

# Shiny Application - P
ui <- fluidPage(
  
  h1("Predictor Application"),

  textInput(
    "modelName",
    label = "Enter a name for your prediction"
  ),
  
  h3("Enter Parameter Values"),
  
  numericInput(
    "totalRev",
    label = "Total Revenue",
    value = mean(dat.df$TOTAL_REVENUE)
  ),
  
  numericInput(
    "totalExp",
    label = "Total Expenditure",
    value = mean(dat.df$TOTAL_EXPENDITURE)
  ),
  
  numericInput(
    "ratioST",
    label = "Student/Teacher Ratio",
    value = mean(dat.df$ALL_STUDENT_TEACHER_RATIO)
  ),

  mainPanel(
    h3(textOutput("model_line")),
    textOutput("param_line"),
    textOutput("model_name"),
    textOutput("total_rev"),
    textOutput("total_exp"),
    textOutput("ratio"),
    textOutput("model_prediction")
  ),

  actionButton("predictionButton", "Predict!")
  
)

server <- function(input, output, session) {
 
  dat <- read.csv("Prediction_inflation_adjusted.csv", header=TRUE)
  dat.df <- as.data.frame(dat)
  
  model.rf <- randomForest(AVG_ALL_SCORES~TOTAL_REVENUE+TOTAL_EXPENDITURE+ALL_STUDENT_TEACHER_RATIO,data=dat.df)
  
  output$model_line <- renderText ({
    paste("Current Model: random forest explaining ", round(tail(model.rf$rsq, n=1)*100), "% of variability of the data")
  })

  output$param_line <- renderText({
    paste("You have selected a model with the following parameters: ")
  })
  
  output$model_name <- renderText({
    paste("Name: ",input$modelName)
  })
  
  output$total_rev <- renderText({
    paste("Total Revenue: ",input$totalRev)
  })
  
  output$total_exp <- renderText({
    paste("Total Expenditure: ",input$totalExp)
  })
  
  output$ratio <- renderText({
    paste("Student/Teacher Ratio: ",input$ratioST)
  })
  
  predOut <- eventReactive(input$predictionButton, {
    new.dat.df <- as.data.frame(cbind(input$totalRev,input$totalExp,input$ratioST))
    colnames(new.dat.df) <- c("TOTAL_REVENUE","TOTAL_EXPENDITURE","ALL_STUDENT_TEACHER_RATIO")
    
    pred <- predict(model.rf,new.dat.df)
    paste("The predicted average of all scores for your parameters is: ", pred)
  })
  
  output$model_prediction <- renderText({
    predOut()
  })
  

}

shinyApp(ui = ui, server = server)
