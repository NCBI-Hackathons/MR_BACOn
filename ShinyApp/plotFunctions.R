# These are all the plotting functions
library(TwoSampleMR)

function_forestplot <- function(dat){
  res_single <- mr_singlesnp(dat)
  p2 <- mr_forest_plot(res_single)
  data_to_plot <- p2[[1]]$data
  fp <- ggplot(data=data_to_plot, aes(x=SNP, y=b, ymin=lo, ymax=up)) +
    geom_pointrange() + 
    geom_hline(yintercept=0, lty=2) +  # add a dotted line at x=1 after flip
    coord_flip() +  # flip coordinates (puts labels on y axis)
    xlab("SNPs") + ylab("Effect Size") +
    ggtitle("This is the forest plot") + 
    theme(text = element_text(size=12),
          axis.text.y = element_text(size=5),plot.title = element_text(hjust = 0.5))
  return(fp)
}


function_funplot <- function(dat){
  res_single <- mr_singlesnp(dat)
  ivw = res_single[res_single$SNP=="All - Inverse variance weighted","b"]
  mregger = res_single[res_single$SNP=="All - MR Egger","b"]
  p4 <- mr_funnel_plot(res_single)
  funnel_data <- p4[[1]]$data
  funplot <- ggplot(data=funnel_data, aes(x=b, y=1/se)) +
    geom_point() +
    labs(title = "This is the funnel plot", x = expression(beta[IV]), y = expression("1/SE"["IV"]), color = "MR Method\n") +
    geom_vline(aes(xintercept=ivw, color="Inverse variance \n weighted"),show.legend =TRUE) +
    geom_vline(aes(xintercept=mregger,color="MR Egger"),show.legend =TRUE) +
    theme(text = element_text(size=12),
          axis.text.y = element_text(size=8),plot.title = element_text(hjust = 0.5))
  return(funplot)
}


function_MRtests <- function(dat){
  res <- mr(dat)
  p1 <- mr_scatter_plot(res, dat)
  mrtests_data <- p1[[1]]$data
  mrtests_plot <- ggplot(data=res, aes(x=method, y=b, ymin=b-se, ymax=b+se)) +
    geom_pointrange() + 
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(title="Effect Size predicted for MR tests")+
    xlab("Tests") + ylab("Effect Size") 
    return(mrtests_plot)
}

#output$OLDMRtests <- renderPlot({
#  res <- mr(dat)
#  p1 <- mr_scatter_plot(res, dat)
#  mrtests_data <- p1[[1]]$data
#  mrtests_plot <- ggplot(data=mrtests_data,aes(x=beta.exposure,y=beta.outcome)) +
#    geom_point() +
#    labs(title=input$tissue,x=paste("SNP effect on",input$metabolite,sep = " "),y=paste("SNP effect on",input$disease,sep = " "))+
#    theme(text = element_text(size=12),
#          axis.text.y = element_text(size=8),plot.title = element_text(hjust = 0.5))
#  print
#  (mrtests_plot)
#})
