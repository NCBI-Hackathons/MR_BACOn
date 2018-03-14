source("plotFunctions.R")
source("backend_functions.R")

server <- function(input, output,session) {
  library(ggplot2)
  #bmi_file <- system.file("data/bmi.txt", package="TwoSampleMR")
  #outcome_dat <- extract_outcome_data(snps=exposure_dat$SNP, outcomes=7)
  #dat <- harmonise_data(exposure_dat, outcome_dat)
  
  choices_metabolites<- reactive({
    choices_metabolites <- get_drop_down_metabolites(input$tissue)
  })
  
  observe({
    updateSelectInput(session = session, inputId = "metabolite", choices = choices_metabolites())
  })
  
  dat_to_run <- reactiveValues(data = data.frame())
  
  observeEvent(input$runif, {
    #met = get_metabolite(input$metabolite,input$tissue)
    if (input$runif !=0){
      t = input$tissue
      m = input$metabolite
      #dat_ret <- perform_mr(t,"",m)
      output$text1 <- renderText({""})
      dat_ret <- tryCatch(perform_mr(t,"",m),error=function(e){return(1)})
      if (dat_ret!=1){
        dat_to_run$data <- as.data.frame(dat_ret)
      }
      else{
        dat_to_run$data <- data.frame()
        output$text1 <- renderText({"No association found"})
      }
    }
    else{
      return()
    }
  })
  observeEvent(input$reset, {
    dat_to_run$data <- data.frame()
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
      ggsave(file, plot = perform_metab_pathway_data("",input$tissue,""), device = device)
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
      paste("HolderForData.csv", sep = "")
    },
    content = function(file) {
      write.csv(dat_to_run$data, file, row.names = FALSE)
    })
  
  output$pathwayPlot <- renderPlot({
    if (nrow(dat_to_run$data)==0){ 
      return()
    }
    else{
      print(perform_metab_pathway_data("",input$tissue,""))
    }
  })
  
}
