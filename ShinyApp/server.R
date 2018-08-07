source("plotFunctions.R")
source("backend_functions_pvalue-cwc.R")
library(ggplot2)

server <- function(input, output,session) {
  
  # This will get values for the drop down for metabolites based on the tissue selected
  choices_metabolites<- reactive({
    choices_metabolites <- get_drop_down_metabolites(input$tissue)
  })
  
  # Update choice of metabolite
  observe({
    updateSelectInput(session = session, inputId = "metabolite", choices = choices_metabolites())
  })
  
  # This data table will be filled only when Run button is clicked
  dat_to_run <- reactiveValues(data = data.frame())
  dat_to_run_pathway <- reactiveValues(data = data.frame())
  # We observe if Run button is clicked
  observeEvent(input$runif, 
               { # If the run button is clicked
                 if (input$runif !=0){
                   output$text1 <- renderText({""})
                   dat_ret <- tryCatch(perform_mr(input$tissue,input$pvalue,"",input$metabolite),error=function(e){return(1)})
                   if (dat_ret!=1){
                     dat_to_run$data <- as.data.frame(dat_ret)
                     dat_to_run_pathway$data <- calculate2MR_pathwayAnalysis(input$metabolite,input$tissue, input$pvalue, "")
                     output$renderUIForOutput <- reactive({'show'})
                     outputOptions(output, 'renderUIForOutput', suspendWhenHidden=FALSE)
                   }
                   else{
                     dat_to_run$data <- data.frame()
                     dat_to_run_pathway$data <-data.frame()
                     output$renderUIForNoAssoc <- reactive({'noassoc'})
                     outputOptions(output, 'renderUIForNoAssoc', suspendWhenHidden=FALSE)
                   }
                 }
                 else{
                   return()
                 }
               })
  
  
  observeEvent(input$reset, {
    dat_to_run$data <- data.frame()
    output$renderUIForNoAssoc <- reactive({'dontshow'})
    outputOptions(output, 'renderUIForNoAssoc', suspendWhenHidden=FALSE)
    output$renderUIForOutput <- reactive({'dontshow'})
    outputOptions(output, 'renderUIForOutput', suspendWhenHidden=FALSE)
  })  
  
  output$forestPlot <- renderPlot({
    if (nrow(dat_to_run$data)==0) {
      return()
    }
    else{
      print(function_forestplot(dat_to_run$data))
    }
  })
  
  output$funnelPlot <- renderPlot({
    if (nrow(dat_to_run$data)==0) {
      return()
    }
    else{
      print(function_funplot(dat_to_run$data))
    }
  })
  
  output$MRtests <- renderPlot({
    if (nrow(dat_to_run$data)==0){ 
      return()
    }
    else{
      print(function_MRtests(dat_to_run$data))
    }
  })
  
  output$downloadFunnelPlot <- downloadHandler(
    filename = function() { paste('funnelOutput', '.png', sep='') },
    content = function(file) {
      device <- function(..., width, height) grDevices::png(..., width = width, height = height, res = 300, units = "in")
      ggsave(file, plot = function_funplot(dat_to_run$data), device = device)
    }
  )
  output$downloadForestPlot <- downloadHandler(
    filename = function() { paste('forestOutput', '.png', sep='') },
    content = function(file) {
      device <- function(..., width, height) grDevices::png(..., width = width, height = height, res = 300, units = "in")
      ggsave(file, plot = function_forestplot(dat_to_run$data), device = device)
    }
  )
  
  output$downloadPathwayPlot <- downloadHandler(
    filename = function() { paste('pathwayOutput', '.png', sep='') },
    content = function(file) {
      device <- function(..., width, height) grDevices::png(..., width = width, height = height, res = 300, units = "in")
      ggsave(file, plot = plot_metab_pathway_data(dat_to_run_pathway$data), device = device)
    }
  )
  
  output$downloadMRTests <- downloadHandler(
    filename = function() { paste('MRTests', '.png', sep='') },
    content = function(file) {
      device <- function(..., width, height) grDevices::png(..., width = width, height = height, res = 300, units = "in")
      ggsave(file, plot = function_MRtests(dat_to_run$data), device = device)
    }
  )
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste('HolderForData', '.csv', sep = '')
    },
    content = function(file) {
      write.csv(dat_to_run$data, file, row.names = FALSE)
    })
  
  output$pathwayPlot <- renderPlot({
    if (nrow(dat_to_run_pathway$data)==0){ 
      return()
    }
    else{
      print(plot_metab_pathway_data(dat_to_run_pathway$data))
    }
  })
  
}
