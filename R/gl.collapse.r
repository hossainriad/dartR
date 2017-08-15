#' Collapse a distance matrix by amalgamating populations
#'
#' This script takes a distance matrix (d, lower matrix) and generates a population recode
#' table to amalgamate populations with distance less than or equal to a specified threshold
#' The distance matrix is generated by gl.fixed.diff()
#'
#' @param fd -- name of the distance matrix produced by gl.fixed.diff() [required]
#' @param gl -- name of the genlight object from which the distance matrix was calculated [required]
#' @param recode.table -- name of the new recode.table to receive the new population reassignments 
#' arising from the amalgamation of populations [default tmp.csv]
#' @param tpop -- max number of fixed differences used amalgamating populations [default 0]
#' @param v -- verbosity = 0, silent; 1, brief; 2, verbose [default 1]
#' @return The new genlight object with recoded populations
#' @import adegenet
#' @export
#' @author Arthur Georges (glbugs@aerg.canberra.edu.au)
#' @examples
#' #only used the first 20 individuals due to runtime reasons 
#' fd <- gl.fixed.diff(testset.gl[1:20,], tloc=0.05)
#' gl <- gl.collapse(fd, testset.gl, recode.table="testset_recode.csv",tpop=1)

gl.collapse <- function(fd, gl, recode.table="tmp.csv", tpop=0, v=1) {
  
  if( v==2) {cat(paste("Creating a new recode_pop table by amalgamating populations for which fd <=",tpop,"\n"))}

# Replace the upper matrix to create a symmetrical matrix of fd
  fd[upper.tri(fd,diag=FALSE)]<-0
  fd <- fd + t(fd)
  
# Store the number of populations in the matrix
  npops <- dim(fd)[1]
  
# Extract the column names
  pops <- variable.names(fd)
  
# Initialize a list to hold the populations that differ by <= tpop
  zero.list <- list()

# For each population, taken row-wise
  for(i in 1:npops){
    # Pull out the columns with fd<=tp
      zero.list[[i]]<- (fd[i,fd[i,]<= tpop])
    # Replace the contents of zero.list with the pop names  
      if (!is.null(names(zero.list[[i]]))) {
        zero.list[[i]]<-names(zero.list[[i]])
      } else {
        zero.list[[i]]<-pops[i]
      }
    # Sort the pop names in each list item  
      zero.list[[i]] <- sort(zero.list[[i]])
  }
  
# Pull out the unique aggregations  
  zero.list <- unique(zero.list)
  
# Amalgamate populations
  for (i in 1:(length(zero.list)-1)) {
    for (j in 2:length(zero.list)) {
      if (length(intersect(zero.list[[i]],zero.list[[j]])) > 0 ) {
        zero.list[[i]] <- union(zero.list[[i]],zero.list[[j]])
        zero.list[[j]] <- union(zero.list[[i]],zero.list[[j]])
      }
    }
  }
  for (i in 1:length(zero.list)) {
    zero.list <- unique(zero.list)
  }

# Print out the results of the aggregations 
  cat("\n\nPOPULATION GROUPINGS\n")
  
  for (i in 1:length(zero.list)) {
    # Create a group label
      if (length(zero.list[[i]])==1) {
        replacement <- zero.list[[i]][1]
      } else {
        replacement <- paste0(zero.list[[i]][1],"+")
      }
      cat(paste0("Group:",replacement,"\n"))
    # Print out the results  
      print(as.character(zero.list[[i]]))
      cat("\n")
    # Create a dataframe with the pop names and their new group names  
      if (i==1) {
        df <- rbind(data.frame(zero.list[[i]],replacement, stringsAsFactors = FALSE))
      } else {
        df <- rbind(df,data.frame(zero.list[[i]],replacement, stringsAsFactors = FALSE))
      }
  }

# Create a recode table corresponding to the aggregations
    #colnames(df) <- c("old","new")
    #rownames(df) <- NULL
    write.table(df, file=recode.table, sep=",", row.names=FALSE, col.names=FALSE)
  
# Recode the data file (genlight object)
  x <- gl.recode.pop(gl, pop.recode=recode.table)
  
  if(setequal(levels(pop(x)),levels(pop(gl)))) { 
    cat(paste("\nPOPULATION GROUPINGS\n     No populations collapsed at fd <=", tpop,"\n"))
    return(gl)
  } else {
    return(x)
  }

}
