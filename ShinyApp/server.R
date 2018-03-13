server <- function(input, output) {
  library(TwoSampleMR)
  library(ggplot2)
  bmi_file <- system.file("data/bmi.txt", package="TwoSampleMR")
  outcome_dat <- extract_outcome_data(snps=exposure_dat$SNP, outcomes=7)
  dat <- harmonise_data(exposure_dat, outcome_dat)
  
  output$forestPlot <- renderPlot({
    
    res_single <- mr_singlesnp(dat)
    p2 <- mr_forest_plot(res_single)
    data_to_plot <- p2[[1]]$data
    fp <- ggplot(data=data_to_plot, aes(x=SNP, y=b, ymin=lo, ymax=up)) +
      geom_pointrange() + 
      geom_hline(yintercept=0, lty=2) +  # add a dotted line at x=1 after flip
      coord_flip() +  # flip coordinates (puts labels on y axis)
      xlab("SNPs") + ylab("Effect Size") +
      ggtitle(input$metabolite) + 
      theme(text = element_text(size=12),
            axis.text.y = element_text(size=5),plot.title = element_text(hjust = 0.5))
    print(fp)
  })
  
  output$funnelPlot <- renderPlot({
    res_single <- mr_singlesnp(dat)
    ivw = res_single[res_single$SNP=="All - Inverse variance weighted","b"]
    mregger = res_single[res_single$SNP=="All - MR Egger","b"]
    p4 <- mr_funnel_plot(res_single)
    funnel_data <- p4[[1]]$data
    funplot <- ggplot(data=funnel_data, aes(x=b, y=1/se)) +
      geom_point() +
      labs(title = input$disease, x = expression(beta[IV]), y = expression("1/SE"["IV"]), color = "MR Method\n") +
      geom_vline(aes(xintercept=ivw, color="Inverse variance \n weighted"),show.legend =TRUE) +
      geom_vline(aes(xintercept=mregger,color="MR Egger"),show.legend =TRUE) +
      theme(text = element_text(size=12),
            axis.text.y = element_text(size=8),plot.title = element_text(hjust = 0.5))
    print(funplot)
    })
  
  output$MRtests <- renderPlot({
    res <- mr(dat)
    p1 <- mr_scatter_plot(res, dat)
    mrtests_data <- p1[[1]]$data
    mrtests_plot <- ggplot(data=mrtests_data,aes(x=beta.exposure,y=beta.outcome)) +
      geom_point() +
      labs(title=input$tissue,x=paste("SNP effect on",input$metabolite,sep = " "),y=paste("SNP effect on",input$disease,sep = " "))+
      theme(text = element_text(size=12),
            axis.text.y = element_text(size=8),plot.title = element_text(hjust = 0.5))
    print
    (mrtests_plot)
  })
  
  # Downloadable csv of selected dataset ----
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("HolderForData.csv", sep = "")
    },
    content = function(file) {
      write.csv(dat, file, row.names = FALSE)
    })
  
}