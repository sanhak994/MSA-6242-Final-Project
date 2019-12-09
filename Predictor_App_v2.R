
# Shiny sandbox for 6242 Project


library(shiny)
library(shinyWidgets)
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
predictors <- colnames(dat)[c(3,7,8,12,13,16,18,22,25,29:35,37,40,42:44,46)]

responses <- c("AVG_ALL_SCORES","grad_rate")

pred <- predict(model.rf,new.dat.df)
pred
years <- unique(dat.df$YEAR)

# Shiny Application - P
ui <- fluidPage(
  navbarPage("Predictor Application",
    tabPanel("Model Building",
        sidebarLayout(
          sidebarPanel(pickerInput("predPicker", "Choose one or more predicting variable(s):", choices = predictors, multiple = TRUE),
                         pickerInput("respPicker", "Choose a reponse variable:", choices = responses, multiple = FALSE),
                         pickerInput("modelPicker", "Choose a model:", choices = c("Standard Linear Regression", "Stepwise Linear Regression","Random Forest"))),
          mainPanel(h2("Model Summary"),
                    verbatimTextOutput("summary"))),
          actionButton("buildButton", "Build Model!")
    ),
  
    tabPanel("Predicting",
        textInput("modelName",label = "Enter a name for your prediction"),
        h3("Enter Parameter Values"),
        numericInput("totalRev",label = "Total Revenue ($MM)",value = round(mean(exp(dat.df$TOTAL_REVENUE))/1000000,digits=3)),
        numericInput("totalExp",label = "Total Expenditure ($MM)",value = round(mean(exp(dat.df$TOTAL_EXPENDITURE))/1000000,digits=3)),
        numericInput("ratioST",label = "Student/Teacher Ratio",value = round(mean(dat.df$ALL_STUDENT_TEACHER_RATIO),digits=0)),
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

  )
)

server <- function(input, output, session) {
  
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
  
  newFit <- eventReactive(input$buildButton, {
    new.formula <- paste(paste(input$respPicker,"~"),paste(input$predPicker,collapse="+"))
    if (input$modelPicker == "Standard Linear Regression") {
      new.model <- lm(new.formula,data=dat)
      summary(new.model)
    }
    else if (input$modelPicker == "Stepwise Linear Regression") {
      new.model <- step(lm(new.formula,data=dat),direction="both",trace=FALSE)
      summary(new.model)
    }
    else {
      new.model <- randomForest(new.formula,data=dat)
      summary(new.model)
    }
  })
  
  output$summary <- renderPrint({
    newFit()
  })
  
  output$model_prediction <- renderText({
    predOut()
  })
  
  
}

shinyApp(ui = ui, server = server)
