#' Report summary of Call Rate for loci or individuals
#'
#' SNP datasets generated by DArT have missing values primarily arising from failure to call a SNP because of a mutation
#' at one or both of the the restriction enzyme recognition sites. This script reports the number of missing values for each
#' of several percentiles. The script gl.filter.callrate() will filter out the loci with call rates below a specified threshold.
#'
#' @param gl -- name of the genlight or genind object containing the SNP data [required]
#' @param method specify the type of report by locus (method="loc") or individual (method="ind") [default method="loc"]
#' @return Mean call rate by locus (method="loc") or individual (method="ind")
#' @export
#' @author Arthur Georges (glbugs@aerg.canberra.edu.au)
#' @examples
#' \dontrun{
#' result <- gl.report.callrate(gl)
#' }

gl.report.callrate <- function(gl, method="loc") {
x <- gl

  if(class(x) == "genlight") {
    cat("Reporting for a genlight object\n")
  } else if (class(x) == "genind") {
    cat("Reporting for a genind object\n")
  } else {
    cat("Fatal Error: Specify either a genlight or a genind object\n")
    stop()
  }
  cat("Note: Missing values most commonly arise from restriction site mutation.\n\n")
  
  if(method == "loc") {
    # Function to determine the loss of loci for a given filter cut-off
    s <- function(gl, percentile) {
      a <- sum(glNA(x,alleleAsUnit=FALSE)<=((1-percentile)*nInd(x)))
      if (percentile == 1) {
        cat(paste0("  Loci with no missing values = ",a," [",round((a*100/nLoc(x)),digits=1),"%]\n"))
      } else {
        cat(paste0("  Loci with less than ",(1-percentile)*100,"% missing values = ",a," [",round((a*100/nLoc(x)),digits=1),"%]\n"))
      }
      return(a)
    }
    # Define vectors to hold the x and y axis values
    b <- vector()
    c <- vector()
    # Generate x and y values
    for (i in seq(0,100,by=5)) {
      c[i+1] <- s(x,((100-i)/100))
      b[i+1] <- i
      if (!is.na(c[i+1])) {
        if ((round(c[i+1]*100/nLoc(x))) == 100) {break}
      }
    }
    b <- 1-(b[!is.na(b)])/100
    c <- c[!is.na(c)]
    df <- data.frame(cbind(b,c)) 
    names(df) <- c("Cutoff","SNPs")
    
  }
    
  if(method == "ind") {
    # Function to determine the loss of individuals for a given filter cut-off
    ind.call.rate <- 1 - rowSums(is.na(as.matrix(x)))/nLoc(x)
    s2 <- function(gl, percentile, i=ind.call.rate) {
      a <- length(i) - length(i[i<=percentile])
      if (percentile == 1) {
        cat(paste0("Individuals no missing values = ",a," [",round((a*100/nInd(x)),digits=1),"%] across loci\n"))
      } else {
        cat(paste0("Individuals with less than ",(1-percentile)*100,"% missing values = ",a," [",round((a*100/nInd(x)),digits=1),"%]\n"))
      }
      return(a)
    }
    # Define vectors to hold the x and y axis values
    b <- vector()
    c <- vector()
    # Generate x and y values
    for (i in seq(0,100,by=5)) {
      c[i+1] <- s2(x,((100-i)/100),ind.call.rate)
      b[i+1] <- i
      if (!is.na(c[i+1])) {
        if ((round(c[i+1]*100/nInd(x))) == 100) {break}
      }
    }
    b <- 1-(b[!is.na(b)])/100
    c <- nInd(x) - c[!is.na(c)]
    df <- data.frame(cbind(b,c)) 
    names(df) <- c("Cutoff","SNPs")
  }

  return("Completed")
}
