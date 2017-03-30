#' Collapse a distance matrix by amalgamating populations
#'
#' This script takes a distance matrix (d in lower matrix) and generates a population recode
#' table to amalgamate populations with distance less than or equal to a specified threshold
#' The distance matrix is generated by gl.fixed.diff()
#'
#' @param fd -- name of the distance matrix produced by gl.fixed.diff() [required]
#' @param gl -- name of the genlight object from which the distance matrix was calculated [required]
#' @param recode.table -- name of the new recode.table to receive the population reassignments 
#' arising from the amalgamation of populations [default tmp.csv]
#' @param t -- the threshold distance value for amalgamating populations [default 0]
#' @param iter -- a parameter to indicate the cycle when gl.collapse() is used interatively [default 1]
#' @return The new genlight object with recoded populations
#' @import adegenet
#' @export
#' @author Arthur Georges and Aaron Adamnack (glbugs@aerg.canberra.edu.au)
#' @examples
#' \dontrun{
#' gl.collapse(fd, gl, outfile=="new_pop_recode.csv",t=0.026)
#' }

gl.collapse <- function(fd, gl, recode.table="tmp.csv", t=0, iter=1) {

  cat(paste("Creating a new recode_pop table by amalgamating populations for which d <",t,"\n"))

# Replace the upper matrix and diagonal with NA
  fd[upper.tri(fd,diag=FALSE)]<-NA
# Store the number of populations in the matrix
  npops <- dim(fd)[1]
# Extract the column names
  pops <- variable.names(fd)
# Accommodate rounding error
  if (t==0) {t <- 0.0001}
# Initialize a list to hold the populations that differ by <= t
  zero.list <- list()

# For each population
  for(i in 1:npops){
  # Identify the other populations for which d <= t
  # Pull out the rows with a zero and the columns with a zero
    rowlist<-which(fd[i,] <= t)
    collist<-which(fd[,i] <= t)
  # Create a list of unique populations and assign to population i
    zero.list[[i]]<-unique(c(rowlist,collist))
  }

# Retain the lists of populations with d <= t against each population
  hold <- zero.list

# Set a counter for the repeat loop
  counter <- 1
# Repeat collapsing the table, exit when there is no change (no change to lengths of the vectors in hold)
  repeat{ # As long as necessary
    countdelta=0
  #message("current step = ",counter)
    for(i in 1:npops){
      #message("i = ",i)
      initvector<-unique(c(i,hold[[i]])) # want initial set of sites that this pop matches; have to have the i in here as some same:same pairs are NA rather than 0....
      initlength<-length(initvector) # get the initial length of the vector
      repeat{
        for(j in 1:dim(fd)[1]){ # loop over all pops...
          #message("j = ",j)
          if(i!=j){ # don't compare self with self
            if(length(intersect(initvector,hold[[j]]))>0){ # if the two intersect
              tempvector<-unique(c(initvector,hold[[j]]))
              initvector<-tempvector[order(tempvector)]
              hold[[j]]<-initvector # update that vector now...
            }
          }
        }
        newlength<-length(initvector)
        if(initlength==newlength){
          break
        }
        initlength<-newlength
        countdelta<-countdelta+1
      }
      hold[[i]]<-initvector
    }
    if(countdelta==0){ # break if there are no changes to any of the vectors
      break
    }
    counter<-counter+1
  }

# Establish a result.table with NAs
  result.table<-as.data.frame(matrix(nrow=npops,ncol=2))

  for(i in 1:length(hold)){
    result.table[i,1]<-pops[i] # put the original name of a row to the inital name for
  # the section below combines the column names for the conversion table
    for(j in 1:length(hold[[i]]>0)){
      if (j==1) {
        new.names<-pops[hold[[i]][j]]
      } else {
        new.names<-paste(new.names,pops[hold[[i]][j]],sep="-")
      }
    }
    result.table[i,2]<-new.names # where the converted name is placed
  }

# Convert the new names to Groups

  n <- unique(result.table[,2])
  n <- n[order(-nchar(n))]
  n <- n[grep("-",n)]
  if (length(n) > 0) {
    cat("\n\nPOPULATION GROUPINGS\n")
    for (i in 1:length(n)) {
      replacement <- paste0("Group_",iter,".",i)
      result.table[,2] <- sub(n[i],replacement,result.table[,2])
      n[i] <- gsub("-",", ",n[i])
      cat(paste(replacement,"\n",n[i],"\n\n"))
    }
    write.table(result.table[,1:2], file=recode.table, sep=",", row.names=FALSE, col.names=FALSE)
    # Recode the data file (genlight object)
    gl <- gl.recode.pop(gl, pop.recode=recode.table)
  } else {
    cat(paste("\nPOPULATION GROUPINGS\n     No populations collapsed, no further improvement at d =", round(t, digits=2),"\n"))
  }

  return(gl)

}
