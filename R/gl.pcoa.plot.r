#' Bivariate plot of the results of a PCoA ordination
#'
#' This script takes output from the ordination generated by gl.pcoa() and plots the individuals classified by population.
#'
#' The factor scores are taken from the output of gl.pcoa() -- an object of class glPca -- and the population assignments are taken from
#' from the original data file. The specimens are shown in a bivariate plot optionally with adjacent labels
#' and enclosing ellipses. Population labels on the plot are shuffled so as not to overlap (using package \{directlabels\}).
#' This can be a bit clunky, as the labels may be some distance from the points to which they refer, but it provides the
#' opportunity for moving labels around using graphics software (Adobe Illustrator).
#'
#' Any pair of axes can be specified from the ordination, provided they are within the range of the nfactors value provided to gl.pcoa(). Axes can be scaled to
#' represent the proportion of variation explained. In any case, the proportion of variation explained by each axis is provided in the axis label.
#'
#'Points displayed in the ordination can be identified if the option labels="interactive" is chosen, in which case the resultant plot is
#'ggplotly() friendly. Running ggplotyly() with no parameters will replot the data and allow identification of points by moving the mouse
#'over them. Refer to the plotly package for further information. Do not forget to load the library via library(plotly).
#'
#' @param glPca Name of the glPca object containing the factor scores and eigenvalues [required]
#' @param data Name of the genlight object containing the SNP genotypes by specimen and population [required]
#' @param scale Flag indicating whether or not to scale the x and y axes in proportion to \% variation explained [default FALSE]
#' @param ellipse Flag to indicate whether or not to display ellipses to encapsulate points for each population [default FALSE]
#' @param p Value of the percentile for the ellipse to encapsulate points for each population [default 0.95]
#' @param labels -- Flag to specify the labels are to be added to the plot. ["none"|"ind"|"pop"|"interactive"|"legend", default = "pop"]
#' @param hadjust Horizontal adjustment of label position [default 1.5]
#' @param vadjust Vertical adjustment of label position [default 1]
#' @param xaxis Identify the x axis from those available in the ordination (xaxis <= nfactors)
#' @param yaxis Identify the y axis from those available in the ordination (yaxis <= nfactors)
#' @return A plot of the ordination
#' @export
#' @import ggplot2 directlabels tidyr
#' @author Arthur Georges (glbugs@@aerg.canberra.edu.au)
#' @examples
#' gl <- testset.gl
#' levels(pop(gl))<-c(rep("Coast",5),rep("Cooper",3),rep("Coast",5),
#' rep("MDB",8),rep("Coast",7),"Em.subglobosa","Em.victoriae")
#' pcoa<-gl.pcoa(gl,nfactors=5)
#' gl.pcoa.plot(pcoa, gl, ellipse=TRUE, p=0.99, labels="pop",hadjust=1.5, vadjust=1)
#' gl.pcoa.plot(pcoa, gl, ellipse=TRUE, p=0.99, labels="pop",hadjust=1.5, vadjust=1, xaxis=1, yaxis=3)

gl.pcoa.plot <- function(glPca, data, scale=FALSE, ellipse=FALSE, p=0.95, labels="pop", hadjust=1.5, 
                         vadjust=1, xaxis=1, yaxis=2) {

  if(class(glPca)!="glPca" | class(data)!="genlight") {
    cat("Fatal Error: glPca and genlight objects required for glPca and data parameters respectively!\n"); stop()
  }
  
  # Tidy up the parameters
  #  if (labels=="smart") { hadjust <- 0; vadjust <- 0 }

  # Create a dataframe to hold the required scores
    m <- cbind(glPca$scores[,xaxis],glPca$scores[,yaxis])
    df <- data.frame(m)
    
  # Convert the eigenvalues to percentages
    s <- sum(glPca$eig)
    e <- round(glPca$eig*100/s,1)
    
  # Labels for the axes
    xlab <- paste("PCoA Axis", xaxis, "(",e[xaxis],"%)")
    ylab <- paste("PCoA Axis", yaxis, "(",e[yaxis],"%)")
    
  # If individual labels

    if (labels == "ind") {
      cat("Plotting individuals\n")
      ind <- indNames(data)
      pop <- factor(pop(data))
      df <- cbind(df,ind,pop)
      colnames(df) <- c("PCoAx","PCoAy","ind","pop")
    
    # Plot
      p <- ggplot(df, aes(x=df$PCoAx, y=df$PCoAy, group=ind, colour=pop)) +
        geom_point(size=2,aes(colour=pop)) +
        geom_dl(aes(label=ind),method="first.points") +
        #ggtitle(paste("PCoA Plot")) +
        theme(axis.title=element_text(face="bold.italic",size="20", color="black"),
              axis.text.x  = element_text(face="bold",angle=0, vjust=0.5, size=10),
              axis.text.y  = element_text(face="bold",angle=0, vjust=0.5, size=10),
              legend.title = element_text(colour="black", size=18, face="bold"),
              legend.text = element_text(colour="black", size = 16, face="bold")
        ) +
        labs(x=xlab, y=ylab) +
        geom_hline(yintercept=0) +
        geom_vline(xintercept=0)
      # Scale the axes in proportion to % explained, if requested
        if(scale==TRUE) { p <- p + coord_fixed(ratio=e[yaxis]/e[xaxis]) }
      # Add ellipses if requested
        if(ellipse==TRUE) {p <- p + stat_ellipse(aes(colour=pop), type="norm", level=0.95)}
    } 
    
    # If population labels

    if (labels == "pop") {
      cat("Plotting populations\n")
      ind <- indNames(data)
      pop <- factor(pop(data))
      df <- cbind(df,ind,pop)
      colnames(df) <- c("PCoAx","PCoAy","ind","pop")
      
      # Plot
      p <- ggplot(df, aes(x=df$PCoAx, y=df$PCoAy, group=pop, colour=pop)) +
        geom_point(size=2,aes(colour=pop)) +
        geom_dl(aes(label=pop),method="smart.grid") +
        #ggtitle(paste("PCoA Plot")) +
        theme(axis.title=element_text(face="bold.italic",size="20", color="black"),
              axis.text.x  = element_text(face="bold",angle=0, vjust=0.5, size=10),
              axis.text.y  = element_text(face="bold",angle=0, vjust=0.5, size=10),
              legend.title = element_text(colour="black", size=18, face="bold"),
              legend.text = element_text(colour="black", size = 16, face="bold")
        ) +
        labs(x=xlab, y=ylab) +
        geom_hline(yintercept=0) +
        geom_vline(xintercept=0) +
        theme(legend.position="none")
      # Scale the axes in proportion to % explained, if requested
      if(scale==TRUE) { p <- p + coord_fixed(ratio=e[yaxis]/e[xaxis]) }
      # Add ellipses if requested
      if(ellipse==TRUE) {p <- p + stat_ellipse(aes(colour="black"), type="norm", level=0.95)}
    }
    
  # If interactive labels

    if (labels=="interactive" | labels=="ggplotly") {
      cat("Preparing a plot for interactive labelling, follow with ggplotly()\n")
      ind <- as.character(indNames(data))
      pop <- as.character(pop(data))
      df <- cbind(df,pop,ind)
      colnames(df) <- c("PCoAx","PCoAy","pop","ind")
      #df$ind <- as.character(df$ind)
      #df$pop <- as.character(df$pop)
      x <- df$PCoAx
      y <- df$PCoAy
      
      # Plot
      p <- ggplot(df, aes(x=x, y=y)) +
        geom_point(size=2,aes(colour=pop, fill=ind)) +
        #geom_dl(aes(label=pop),method="smart.grid") +
        #ggtitle(paste("PCoA Plot")) +
        theme(axis.title=element_text(face="bold.italic",size="20", color="black"),
              axis.text.x  = element_text(face="bold",angle=0, vjust=0.5, size=10),
              axis.text.y  = element_text(face="bold",angle=0, vjust=0.5, size=10),
              legend.title = element_text(colour="black", size=18, face="bold"),
              legend.text = element_text(colour="black", size = 16, face="bold")
        ) +
        labs(x=xlab, y=ylab) +
        geom_hline(yintercept=0) +
        geom_vline(xintercept=0) +
        theme(legend.position="none")
      # Scale the axes in proportion to % explained, if requested
      if(scale==TRUE) { p <- p + coord_fixed(ratio=e[yaxis]/e[xaxis]) }
      # Add ellipses if requested
      if(ellipse==TRUE) {p <- p + stat_ellipse(aes(colour=pop), type="norm", level=0.95)}
       cat("Ignore any warning on the number of shape categories\n")
    }  
    
  # If labels = legend

    if (labels == "legend") {
      cat("Plotting populations identified by a legend\n")
      pop <- factor(pop(data))
      df <- cbind(df,pop)
      colnames(df) <- c("PCoAx","PCoAy","pop")
      
      # Plot
      p <- ggplot(df, aes(x=df$PCoAx, y=df$PCoAy,colour=pop)) +
        geom_point(size=2,aes(colour=pop)) +
        #geom_dl(aes(label=ind),method="first.points") +
        #ggtitle(paste("PCoA Plot")) +
        theme(axis.title=element_text(face="bold.italic",size="20", color="black"),
              axis.text.x  = element_text(face="bold",angle=0, vjust=0.5, size=10),
              axis.text.y  = element_text(face="bold",angle=0, vjust=0.5, size=10),
              legend.title = element_text(colour="black", size=18, face="bold"),
              legend.text = element_text(colour="black", size = 16, face="bold")
        ) +
        labs(x=xlab, y=ylab) +
        geom_hline(yintercept=0) +
        geom_vline(xintercept=0)
      # Scale the axes in proportion to % explained, if requested
      if(scale==TRUE) { p <- p + coord_fixed(ratio=e[yaxis]/e[xaxis]) }
      # Add ellipses if requested
      if(ellipse==TRUE) {p <- p + stat_ellipse(aes(colour=pop), type="norm", level=0.95)}
    } 
    
    # If labels = none
    
    if (labels == "none" | labels==FALSE) {
      cat("Plotting points with no labels\n")
      pop <- factor(pop(data))
      df <- cbind(df,pop)
      colnames(df) <- c("PCoAx","PCoAy","pop")
      
      # Plot
      p <- ggplot(df, aes(x=df$PCoAx, y=df$PCoAy,colour=pop)) +
        geom_point(size=2,aes(colour=pop)) +
        #geom_dl(aes(label=ind),method="first.points") +
        #ggtitle(paste("PCoA Plot")) +
        theme(axis.title=element_text(face="bold.italic",size="20", color="black"),
              axis.text.x  = element_text(face="bold",angle=0, vjust=0.5, size=10),
              axis.text.y  = element_text(face="bold",angle=0, vjust=0.5, size=10),
              legend.title = element_text(colour="black", size=18, face="bold"),
              legend.text = element_text(colour="black", size = 16, face="bold")
        ) +
        labs(x=xlab, y=ylab) +
        geom_hline(yintercept=0) +
        geom_vline(xintercept=0)+
        theme(legend.position="none")
      # Scale the axes in proportion to % explained, if requested
      if(scale==TRUE) { p <- p + coord_fixed(ratio=e[yaxis]/e[xaxis]) }
      # Add ellipses if requested
      if(ellipse==TRUE) {p <- p + stat_ellipse(aes(colour=pop), type="norm", level=0.95)}
    }

  # If interactive labels
    
    #if (labels=="interactive" | labels=="ggplotly") {
    #  ggplotly(p)
    #} else {
      p
    #}
    
  return (p)
}
