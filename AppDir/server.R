library(shiny)
library(shinyWidgets)
library(ggplot2)
library(randomForest)

# Some references:
# https://stackoverflow.com/questions/19130455/create-dynamic-number-of-input-elements-with-r-shiny
# https://stackoverflow.com/questions/50795355/how-to-extract-the-values-of-dynamically-generated-inputs-in-shiny

server <- function(input, output, session) {
  
  dataAddedBool <- reactiveValues(default=FALSE,custom=FALSE)
  
  ## Data Loading Tab
  
  defaultDat <- reactive({
    
    if (is.null(input$defaultFilePicker))
      return(NULL)
    
    inFile <- input$defaultFilePicker
    
    if (is.null(inFile))
      paste("Error loading data!")
    
    dataAddedBool$default <- TRUE
    default.dat.table <- read.csv(inFile$datapath)
    
  })
  
  viewDefaultDataHeader <- eventReactive(input$confirmDefaultButton, {
    head(defaultDat())
  })
  
  output$defaultDataTableOutput <- renderTable({
    viewDefaultDataHeader()
  },spacing='xs',striped=TRUE)
  
  
  customDat <- reactive({
    
    if (is.null(input$customFilePicker))
      return(NULL)
    
    inFile <- input$customFilePicker
    
    if (is.null(inFile))
      paste("Error loading data!")
    
    dataAddedBool$custom <- TRUE
    dat.table <- read.csv(inFile$datapath)
    
  })
  
  viewCustomDataHeader <- eventReactive(input$confirmCustomButton, {
    head(customDat())
  })
  
  output$customDataTableOutput <- renderTable({
    viewCustomDataHeader()
  },spacing='xs',striped=TRUE)
  
  ## Data dict tab
  
  data.dict <- reactive({
    
    if (is.null(input$dataDictPicker))
      return(NULL)
    
    inFile <- input$dataDictPicker
    
    if (is.null(inFile))
      paste("Error loading data!")
    
    #dataAddedBool$added <- TRUE
    data.dict.table <- read.csv(inFile$datapath)
    
  })
  
  viewDataDict <- eventReactive(input$viewDictButton, {
    data.dict()
  })
  
  output$dataDictOutput <- renderTable({
    
    viewDataDict()
    
  },striped=TRUE)
  
  
  ## Model Building Tab
  modelBuiltBool <- reactiveValues(built=FALSE)
  
  output$initializeParams <- renderUI({

    if (!dataAddedBool$default | !dataAddedBool$custom) {
      return(paste("Please add and confirm data before building a model"))
    }
    # Columns 1-14 are predictors
    pickerInput("predPicker", "If using a custom model, choose one or more predicting variable(s):", choices = colnames(customDat())[1:14], options = list(`actions-box` = TRUE), multiple = TRUE)
  })
  
  output$initializeResponse <- renderUI({
    if (!dataAddedBool$default | !dataAddedBool$custom) {
      return()
    }
    # Columns 15 and 16 are the response variables
    pickerInput("respPicker", "If using a custom model, choose a response variable:", choices = colnames(customDat())[15:16], multiple = FALSE)
  })
  
  output$initializeModel <- renderUI({
    if (!dataAddedBool$default | !dataAddedBool$custom) {
      return()
    }
    pickerInput("modelPicker", "Choose a model:", choices = c("Default Linear Regression","Default Boosted Tree","Custom Linear Regression","Custom Decision Tree","Custom Random Forest","Custom Neural Network"))
  })
  
  output$initializeBuildButton <- renderUI({
    if (!dataAddedBool$default | !dataAddedBool$custom) {
      return()
    }
    actionButton("buildButton", "Build Model!")
  })
  
  output$initializeSummary <- renderUI({
    if (!dataAddedBool$default | !dataAddedBool$custom) {
      return()
    }
    
    if (dataAddedBool$default & dataAddedBool$custom) {
      
      tryCatch({
        
        if (input$modelPicker == "Default Linear Regression") {
          HTML(paste(h2("Default Linear Regression Model Summary"),"<br>","<b>Response:</b> AVG_ALL_SCORES",
               "<br>","<b>Predictors:</b> MEDIAN_INCOME, FEDERAL_REVENUE, LOCAL_REVENUE, ALL_STUDENT_TEACHER_RATIO"))
        }
        
        else if (input$modelPicker == "Default Boosted Tree") {
          HTML(paste(h2("Default Boosted Tree Model Summary"),"<br>","<b>Response:</b> AVG_ALL_SCORES",
                     "<br>","<b>Predictors:</b> FEDERAL_REVENUE, STATE_REVENUE,LOCAL_REVENUE,",
                     "<br>", "INSTRUCTION_EXPENDITURE, SUPPORT_SERVICES_EXPENDITURE, CAPITAL_OUTLAY_EXPENDITURE,",
                     "<br>", "MEDIAN_INCOME, ALL_STUDENT_TEACHER_RATIO, ALL_STUDENTS"))
        }
        
        else {
          HTML(paste(h2("Custom Model Summary")))
        }
        
      }, error = function(e) {
        HTML(paste())
      })

    }
    
  })
  
  newFit <- eventReactive(input$buildButton, {
    new.formula <- paste(paste(input$respPicker,"~"),paste(input$predPicker,collapse="+"))
    
    modelBuiltBool$built <- TRUE
    
    if (input$modelPicker == "Default Linear Regression") {
      new.model <- lm(AVG_ALL_SCORES~MEDIAN_INCOME+FEDERAL_REVENUE+LOCAL_REVENUE+ALL_STUDENT_TEACHER_RATIO,data=defaultDat())
      summary(new.model)
    }
    else if (input$modelPicker == "Default Boosted Tree") {
      new.formula <- as.formula("AVG_ALL_SCORES~FEDERAL_REVENUE+STATE_REVENUE+LOCAL_REVENUE+INSTRUCTION_EXPENDITURE+SUPPORT_SERVICES_EXPENDITURE+CAPITAL_OUTLAY_EXPENDITURE+MEDIAN_INCOME+ALL_STUDENT_TEACHER_RATIO+ALL_STUDENTS")
      new.model <- gbm(as.formula(new.formula),data=defaultDat(),distribution = "gaussian",shrinkage=0.1)
      summary(new.model)
    }
    else if (input$modelPicker == "Custom Linear Regression") {
      new.model <- lm(new.formula,data=customDat())
      summary(new.model)
    }
    else if (input$modelPicker == "Custom Decision Tree") {
      new.model <- rpart(new.formula,data=customDat())
      summary(new.model)
    }
    else if (input$modelPicker == "Custom Random Forest") {
      new.model <- randomForest(as.formula(new.formula),data=customDat())
      importance(new.model)
    }
    else if (input$modelPicker == "Custom Neural Network") {
      new.model <- neuralnet(new.formula,data=customDat())
      prediction(new.model)
    }
    
  })
  
  output$summary <- renderPrint({
    newFit()
  })
  
  ## Predicting Tab

  output$modelLine <- renderUI ({
    if (!dataAddedBool$default | !dataAddedBool$custom | !modelBuiltBool$built) {
      return()
    }
    h3(paste("Current Model: ", input$modelPicker))
  })
  
  output$paramValsLine <- renderUI ({
    if (!dataAddedBool$default | !dataAddedBool$custom | !modelBuiltBool$built) {
      return("Please confirm data and build model before predicting")
    }
    paste("Enter Parameter Values")
  })
  
  output$params <- renderUI({
    
    if (!dataAddedBool$default | !dataAddedBool$custom | !modelBuiltBool$built) {
      return()
    }
    
    if (input$modelPicker == "Default Linear Regression") {
      
      preds.list <- list("MEDIAN_INCOME","FEDERAL_REVENUE","LOCAL_REVENUE","ALL_STUDENT_TEACHER_RATIO")
      
      lapply(1:length(preds.list), function(i) {
        
        col.index <- match(preds.list[i],colnames(defaultDat()))

        min.val <- round(-2*abs(2*min(defaultDat()[,col.index])),2)
        max.val <- round(2*max(defaultDat()[,col.index]),2)

        sliderInput(
          inputId = paste0(preds.list[i],"_ID"),
          label = preds.list[i],
          min = min.val,
          max = max.val,
          value = max(defaultDat()[,col.index]),
          round = -2,
          step = 0.01
        )

      })
      
    }
    
    else if (input$modelPicker == "Default Boosted Tree") {

      preds.list <- list("FEDERAL_REVENUE","STATE_REVENUE","LOCAL_REVENUE","INSTRUCTION_EXPENDITURE","SUPPORT_SERVICES_EXPENDITURE","CAPITAL_OUTLAY_EXPENDITURE","MEDIAN_INCOME","ALL_STUDENT_TEACHER_RATIO","ALL_STUDENTS")
      
      lapply(1:length(preds.list), function(i) {
        
        col.index <- match(preds.list[i],colnames(defaultDat()))
        
        min.val <- round(-2*abs(2*min(defaultDat()[,col.index])),2)
        max.val <- round(2*max(defaultDat()[,col.index]),2)
        
        sliderInput(
          inputId = paste0(preds.list[i],"_ID"),
          label = preds.list[i],
          min = min.val,
          max = max.val,
          value = max(defaultDat()[,col.index]),
          round = -2,
          step = 0.01
        )
        
      })
      
    }
    
    else {
      lapply(1:length(input$predPicker), function(i) {
        
        col.index <- match(input$predPicker[i],colnames(customDat()))
        
        min.val <- round(-2*abs(2*min(customDat()[,col.index])),2)
        max.val <- round(2*max(customDat()[,col.index]),2)
        
        sliderInput(
          inputId = paste0(input$predPicker[i],"_ID"),
          label = input$predPicker[i],
          min = min.val,
          max = max.val,
          value = mean(customDat()[,col.index]),
          round = -2,
          step = 0.01
        )
        
      })   
    }
    
  })
  
  output$initializePredictionButton <- renderUI({
    if (!dataAddedBool$default | !dataAddedBool$custom | !modelBuiltBool$built) {
      return()
    }
    actionButton("predictionButton", "Predict!")
  })
  
  predOut <- eventReactive(input$predictionButton, {
    
    if (input$modelPicker == "Default Linear Regression") {
      
      preds.list <- list("MEDIAN_INCOME","FEDERAL_REVENUE","LOCAL_REVENUE","ALL_STUDENT_TEACHER_RATIO")
      
      vals <- lapply(1:length(preds.list), function(i) {
        input[[ paste0(preds.list[i],"_ID")]]
      })
    }
    
    else if (input$modelPicker == "Default Boosted Tree") {
      
      preds.list <- list("FEDERAL_REVENUE","STATE_REVENUE","LOCAL_REVENUE","INSTRUCTION_EXPENDITURE","SUPPORT_SERVICES_EXPENDITURE","CAPITAL_OUTLAY_EXPENDITURE","MEDIAN_INCOME","ALL_STUDENT_TEACHER_RATIO","ALL_STUDENTS")
      
      vals <- lapply(1:length(preds.list), function(i) {
        input[[ paste0(preds.list[i],"_ID")]]
      })
    }
    
    else {
      vals <- lapply(1:length(input$predPicker), function(i) {
        input[[ paste0(input$predPicker[i],"_ID")]]
      })  
    }
    
    new.dat.df <- as.data.frame(vals)
    
    if (input$modelPicker == "Default Linear Regression") {
      
      colnames(new.dat.df) <- c("MEDIAN_INCOME","FEDERAL_REVENUE","LOCAL_REVENUE","ALL_STUDENT_TEACHER_RATIO")
      
      new.model <- lm(AVG_ALL_SCORES~MEDIAN_INCOME+FEDERAL_REVENUE+LOCAL_REVENUE+ALL_STUDENT_TEACHER_RATIO,data=defaultDat())
      pred <- predict(new.model,newdata=new.dat.df)
      
      HTML("The predicted value of AVG_ALL_SCORES given your parameters is:",
           "<b>", paste(round(pred)), "</b>","<br>", "(Scores range from 0-500)")
    }
    
    else if (input$modelPicker == "Default Boosted Tree") {
      
      colnames(new.dat.df) <- c("FEDERAL_REVENUE","STATE_REVENUE","LOCAL_REVENUE","INSTRUCTION_EXPENDITURE","SUPPORT_SERVICES_EXPENDITURE","CAPITAL_OUTLAY_EXPENDITURE","MEDIAN_INCOME","ALL_STUDENT_TEACHER_RATIO","ALL_STUDENTS")
  
      new.formula <- as.formula("AVG_ALL_SCORES~FEDERAL_REVENUE+STATE_REVENUE+LOCAL_REVENUE+INSTRUCTION_EXPENDITURE+SUPPORT_SERVICES_EXPENDITURE+CAPITAL_OUTLAY_EXPENDITURE+MEDIAN_INCOME+ALL_STUDENT_TEACHER_RATIO+ALL_STUDENTS")
      
      new.model <- gbm(as.formula(new.formula),data=defaultDat(),distribution="gaussian",shrinkage=0.1)
      pred <- predict(new.model,newdata=new.dat.df,n.trees=100)
      
      HTML("The predicted value of AVG_ALL_SCORES given your parameters is:",
           "<b>", paste(round(pred)), "</b>","<br>", "(Scores range from 0-500)")
    }
    
    else {
      
      # Custom model
      
      for (i in 1:length(input$predPicker)) {
        colnames(new.dat.df)[i] <- input$predPicker[i]
      }
      
      new.formula <- paste(paste(input$respPicker,"~"),paste(input$predPicker,collapse="+"))
      
      if (input$modelPicker == "Custom Linear Regression") {
        new.model <- lm(new.formula,data=customDat())
        pred <- predict(new.model,new.dat.df)
      }
      else if (input$modelPicker == "Custom Decision Tree") {
        new.model <- rpart(new.formula,data=customDat())
        pred <- predict(new.model,new.dat.df)
      }
      else if (input$modelPicker == "Custom Random Forest") {
        new.model <- randomForest(as.formula(new.formula),data=customDat())
        pred <- predict(new.model,new.dat.df)
      }
      else if (input$modelPicker == "Custom Neural Network") {
        new.model <- neuralnet(new.formula,data=customDat())
        pred <- predict(new.model,new.dat.df)
      }
      
      if (input$respPicker == "AVG_ALL_SCORES") {
        HTML("The predicted value of",input$respPicker,"given your parameters is:",
             "<b>", paste(round(pred)), "</b>","<br>", "(Scores range from 0-500)")
      }
      
      else if (input$respPicker == "grad_rate") {
        HTML(paste0("The predicted value of ",input$respPicker," given your parameters is: ",
                    "<b>", paste(round(pred)),"</b>","%"))
      }
    }
    
  })
  
  output$modelPrediction <- renderUI({
    if (!dataAddedBool$default | !dataAddedBool$custom | !modelBuiltBool$built) {
      return()
    }
    predOut()
  })
  
  
}