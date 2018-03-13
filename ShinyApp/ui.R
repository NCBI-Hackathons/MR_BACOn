library(shiny)

renderInputs <- function(prefix) {
  wellPanel(
    fluidRow(
      column(3,
             selectInput(inputId='tissue', label ='Tissue', choices =c("Urine","Serum"))),
      column(3,
             selectInput(inputId='metabolite', label ='Metabolite', choices = NULL)),
      column(3,
             selectInput(inputId='disease', label = 'Disease', choices =c("Coronary Heart Disease")))
    )
    
  )
}

# Define UI for application 
fluidPage(theme="simplex.min.css",
          tags$style(type="text/css",
                     "label {font-size: 12px;}",
                     ".recalculating {opacity: 1.0;}"
          ),
          
          # Application title
          tags$h2("MR BACOn: Biomarker Associations for Causality with Outcomes"),
          #p("An adaptation of the",
          #  tags$a(href="http://glimmer.rstudio.com/systematicin/retirement.withdrawal/", "retirement app"),
          #  "from",
          #  tags$a(href="http://systematicinvestor.wordpress.com/", "Systematic Investor"),
          #  "to demonstrate the use of Shiny's new grid options."),
          p("Find causal associations between your metabolite of interest and disease."),
          hr(),
          
          fluidRow(
            column(6, tags$h3("Inputs"))
            #column(6, tags$h3("Scenario B"))
          ),
          fluidRow(
            renderInputs("a")
            #column(6, renderInputs("b"))
          ),
          fluidRow(
            column(6,tags$h3("MR Tests"))
          ),
          fluidRow(
            # Button
            column(6,downloadButton("downloadMRTests", "Download"))
          ),
          fluidRow(
            column(6,
                   plotOutput("MRtests", height = "600px")
            )
          ),
          fluidRow(
            column(6,tags$h3("Funnel Plot")),
            column(6,tags$h3("Forest Plot"))
          ),
          fluidRow(
            # Button
            column(6,downloadButton("downloadFunnelPlot", "Download")),
            column(6,downloadButton("downloadForestPlot", "Download"))
          ),
          fluidRow(
            column(6,
                   plotOutput("funnelPlot", height = "600px")
            ),
            column(6,
                   plotOutput("forestPlot", height = "600px")
            )
          ),
          fluidRow(
            # Button
            downloadButton("downloadData", "Download")
          )
)