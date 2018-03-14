source("plotFunctions.R")

server <- function(input, output,session) {
  library(ggplot2)
  #bmi_file <- system.file("data/bmi.txt", package="TwoSampleMR")
  #outcome_dat <- extract_outcome_data(snps=exposure_dat$SNP, outcomes=7)
  #dat <- harmonise_data(exposure_dat, outcome_dat)

  choices_metabolites<- reactive({
    if (input$tissue=="Urine"){
      choices_metabolites <- as.character(levels(read.table("data/metab_info/urine_map.txt",sep="\t",header=TRUE)$metabolite))
    }
    else if (input$tissue=="Serum") {
      choices_metabolites <- as.character(levels(read.table("data/metab_info/serum_map.txt",sep="\t",header=TRUE)$metabolite))
    }
  })
  
  observe({
    updateSelectInput(session = session, inputId = "metabolite", choices = choices_metabolites())
  })
  
  dat_to_run <- reactiveValues(data = NULL)
  
  observeEvent(input$runif, {
    dat_to_run$data <- read.table("testdata.tsv",sep="\t",header = TRUE)
  })
  observeEvent(input$reset, {
    dat_to_run$data <- NULL
  })  
  
  output$forestPlot <- renderPlot({
    if (is.null(dat_to_run$data)) {
      return()
    }
    else{
      print(function_forestplot(dat_to_run$data))
    }
  })
  
  output$funnelPlot <- renderPlot({
    if (is.null(dat_to_run$data)) {
      return()
    }
    else{
    print(function_funplot(dat_to_run$data))
    }
  })
  
  output$MRtests <- renderPlot({
    if (is.null(dat_to_run$data)){ 
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
      ggsave(file, plot = function_funplot(), device = device)
    }
  )
  output$downloadForestPlot <- downloadHandler(
    filename = function() { paste('forestOutput', '.png', sep='') },
    content = function(file) {
      device <- function(..., width, height) grDevices::png(..., width = width, height = height, res = 300, units = "in")
      ggsave(file, plot = function_forestplot(), device = device)
    }
  )
  
  output$downloadMRTests <- downloadHandler(
    filename = function() { paste('MRTests', '.png', sep='') },
    content = function(file) {
      device <- function(..., width, height) grDevices::png(..., width = width, height = height, res = 300, units = "in")
      ggsave(file, plot = function_MRtests(), device = device)
    }
  )
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("HolderForData.csv", sep = "")
    },
    content = function(file) {
      write.csv(dat, file, row.names = FALSE)
    })
  
  
  
}
