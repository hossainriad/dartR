#' Report loci containing secondary SNPs in a genlight \{adegenet\} object 
#'
#' SNP datasets generated by DArT include fragments with more than one SNP (that is, with secondaries) and record them separately with the same CloneID (=AlleleID).
#' These multiple SNP loci within a fragment are likely to be linked, and so you may wish to remove secondaries.
#' 
#' The script reports statistics associated with secondaries, and the consequences of filtering them out, and provides
#' three plots. The first is a Box and Whisker plot adjusted to account for skewness, the second is a bargraph of
#' the frequency of secondaries per sequence tag, and the third is Poisson expectation for those frequencies
#' including an estimate of the zero class (no. of sequence tags with no SNP scored).
#' 
#' Heterozygosity in gl.report.heterozygosity is expressed as a proportion is in a sense relative, because it is calculated
#' against a background of only those loci that are polymorphic somewhere in the dataset.
#' To allow intercomparability across studies and species, any measure of heterozygosity
#' needs to accommodate loci that are invariant. However, the number of invariant loci
#' are unknown given the SNPs are detected as single point mutational variants, and
#' because of the particular additional filtering pre-analysis. Modelling the counts
#' of SNPs per sequence tag as a Poisson distribution in this script allows estimate of the zero class,
#' that is, the number of invariant loci. This is reported, and the veracity of the 
#' estimate can be assessed by the correspondence of the observed frequencies against
#' those under Poisson expectation in the associated graphs. It can then be optionally
#' provided to gl.report.heterozygosity via the parameter n.invariants.
#'
#' @param x -- name of the genlight object containing the SNP data [required]
#' @param plot -- if TRUE, will produce a frequency plot the number of SNPs per sequence tag [default = FALSE] 
#' @param boxplot -- if 'standard', plots a standard box and whisker plot; if 'adjusted',
#' plots a boxplot adjusted for skewed distributions [default 'adjusted']
#' @param range -- specifies the range for delimiting outliers [default = 1.5 interquartile ranges]
#' @param verbose level of verbosity. verbose=0 is silent, verbose=1 returns more detailed output during conversion.
#' @return A genlight object of loci with multiple SNP calls
#' @importFrom adegenet glPlot
#' @importFrom graphics barplot
#' @importFrom robustbase adjbox
#' @importFrom stats dpois
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' gl.report.secondaries(testset.gl, plot=TRUE)

gl.report.secondaries <- function(x, 
                                  plot=FALSE, 
                                  boxplot="adjusted",
                                  range=1.5,
                                  verbose = 0) {

# TIDY UP FILE SPECS

  funname <- match.call()[[1]]

# FLAG SCRIPT START

    cat("Starting",funname,"\n")

# STANDARD ERROR CHECKING
  
  if(class(x)!="genlight") {
    cat("  Fatal Error: genlight object required!\n"); stop("Execution terminated\n")
  }
    
  if (!(boxplot=="standard" | boxplot=="adjusted")) {
    cat("Warning: Box-whisker plots must either standard or adjusted for skewness, set to boxplot='adjusted'\n")
    boxplot <- 'adjusted'   
  }
    
  # Work around a bug in adegenet if genlight object is created by subsetting
      if (nLoc(x)!=nrow(x@other$loc.metrics)) { stop("The number of rows in the loc.metrics table does not match the number of loci in your genlight object!")  }

  # Set a population if none is specified (such as if the genlight object has been generated manually)
    if (is.null(pop(x)) | is.na(length(pop(x))) | length(pop(x)) <= 0) {
      if (verbose >= 1){ cat("  Population assignments not detected, individuals assigned to a single population labelled 'pop1'\n")}
      pop(x) <- array("pop1",dim = nInd(x))
      pop(x) <- as.factor(pop(x))
    }

# DO THE JOB

# Extract the clone ID number
  a <- strsplit(as.character(x@other$loc.metrics$AlleleID),"\\|")
  b <- unlist(a)[ c(TRUE,FALSE,FALSE) ]
  cat("Counting ....\n")
  x.secondaries <- x[,duplicated(b)]
     # Work around a bug in adegenet if genlight object is created by subsetting
     x.secondaries@other$loc.metrics <- x.secondaries@other$loc.metrics[1:nLoc(x),]
  # df <- data.frame(CloneID=unique(b[duplicated(b)]), freq=as.numeric(table(b)[table(b)>1]))  

  nloc.with.secondaries <- table(duplicated(b))[2]
  if (!is.na(nloc.with.secondaries)){
    # Prepare for plotting
    # Save the prior settings for mfrow, oma, mai and pty, and reassign
    op <- par(mfrow = c(3, 1), oma=c(1,1,1,1), mai=c(0.5,0.5,0.5,0.5),pty="m")
    # Set margins for first plot
    par(mai=c(0.6,0.5,0.5,0.5))
    # Plot Box-Whisker plot
    adjbox(c(0,as.numeric(table(b))),
           horizontal = TRUE,
           col='red',
           range=range,
           main = "Box and Whisker Plot")
    # Set margins for second plot
    par(mai=c(0.5,0.5,0.2,0.5))  
    # Plot Histogram
    freqs <- c(0,table(as.numeric(table(b))))
    f <- as.table(freqs)
    names(f)<- seq(1:(length(f)))-1
    barplot(f,col="red", space=0.5, main="Observed Frequency of SNPs per Sequence Tag")
    
    # Plot Histogram with estimate of the zero class
    cat("Estimating parameters (lambda) of the Poisson expectation\n")
      # Calculate the mean for the truncated distribution
        freqs <- as.numeric(freqs)
        tmp<- NA
        for (i in 1:length(freqs)){
          tmp[i] <- freqs[i]*(i-1)
        }
        tmean <- sum(tmp)/sum(freqs)
      # Set a random seed, close to 1
        seed <- tmean
      # Set convergence criterion
        delta <- 0.00001
      # Use the mean of the truncated distribution to compute lambda for the untruncated distribution
        k <- seed
        for (i in 1:100){
          print(k)
          k.new <- tmean*(1-exp(-k))
          if (abs(k.new - k) <= delta){
            cat("Converged on Lambda of",k.new,"\n")
            break
          }
          if (i == 100){
            cat("Failed to converge")
            break
          }
          k <- k.new
        }
        
      # Size of the truncated distribution
        n <- sum(freqs)  # Size of the truncated set 
        tp <- 1 - dpois( x=0, lambda=k ) # Fraction that is the truncated set
        rn <- round(n/tp,0) # Estimate of the whole set
        cat("Estimated size of the zero class",round(dpois(x=0,lambda=k)*rn,0),"\n")
      # Table for the reconstructed set  
        reconstructed <- dpois( x=0:(length(freqs)-1), lambda=k )*rn
        reconstructed <- as.table(reconstructed)
        names(reconstructed)<- seq(1:(length(reconstructed)))-1
        # Set margins for third plot
        par(mai=c(0.5,0.5,0.2,0.5))
        title <- paste0("Poisson Expectation (zero class ",round(dpois(x=0,lambda=k)*rn,0)," invariant loci)")
        barplot(reconstructed,col="red", space=0.5, main=title)
        # Reset the par options    
        par(op)
        
  } else {
      if (plot) {cat("  Warning: No loci with secondaries, no plot produced\n") }
  }
  
# Identify secondaries in the genlight object
  cat("  Total number of SNP loci scored:",nLoc(x),"\n")
  if (is.na(table(duplicated(b))[2])) {
    cat("   Number of secondaries: 0 \n")
  } else {
    cat("   Number of sequence tags in total:",table(duplicated(b))[1],"\n")
    cat("   Estimated number of invariant sequence tags:", round(dpois(x=0,lambda=k)*rn,0),"\n")
    cat("   Number of sequence tags with secondaries:",sum(table(as.numeric(table(b))))-table(as.numeric(table(b)))[1],"\n")
    cat("   Number of secondary SNP loci that would be removed on filtering:",table(duplicated(b))[2],"\n")
    cat("   Number of SNP loci that would be retained on filtering:",table(duplicated(b))[1],"\n")
    cat(" Tabular 1 to K secondaries (refer plot)\n",table(as.numeric(table(b))),"\n")
  }  
  cat("\nReturning a genlight object containing only those loci with secondaries (multiple entries per locus)\n\n")

# FLAG SCRIPT END
  

    cat("Completed:",funname,"\n")

    return(x.secondaries)
  
}  
