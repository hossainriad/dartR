#' Create or edit a individual (=specimen) names and create an recode_ind file
#' 
#' A script to edit individual names in a genlight object, or to 
#' create a reassignment table taking the individual labels
#' from a genlight object, or to edit existing individual labels in
#' an existing recode_ind file.
#' 
#' Renaming individuals may be required when there have been errors in labelling arising
#' in the process from sample to DArT files. There may be occasions where renaming
#' individuals is required for preparation of figures. Caution needs to be exercised
#' because of the potential for breaking the "chain of evidence" between the samples themselves
#' and the analyses. REcoding individuals can be done with a recode table (csv).
#' 
#' This script will input an existing recode table for editting and
#' optionally save it as a new table, or if the name of an input table is not
#' supplied, will generate a table using the individual labels in the 
#' parent genlight object.
#' 
#' The script, having deleted individuals, identifies resultant monomorphic loci or loci
#' with all values missing and deletes them (using gl.filter.monomorphs.r)
#' 
#' The script returns a genlight object with the new individual labels.
#' 
#' @param gl Name of the genlight object for which individuals are to be relabelled.[required]
#' @param ind.recode Name of the file to output the new assignments [optional]
#' @return An object of class ("genlight") with the revised individual labels
#' @import utils
#' @export
#' @author Arthur Georges (glbugs@aerg.canberra.edu.au)
#' @examples
#' \dontrun{
#' gl <- gl.edit.recode.ind(gl)
#' gl <- gl.edit.recode.ind(gl, pop.recode="ind.recode.table.csv")
#' gl <- gl.edit.recode.ind(gl, pop.recode="ind.recode.table.csv", 
#' }
#' #Ammended Georges 9-Mar-17

gl.edit.recode.ind <- function(gl, ind.recode=NULL) {
  
# Take assignments from gl  

  cat("Extracting current individual labels from the gl object\n")
  recode.table <- cbind(indNames(gl),indNames(gl))

# Create recode table for editting, and bring up the editor
    new <- as.matrix(edit(recode.table))
    new <- new[,1:2]

# Write out the recode table, if requested
  if (is.null(ind.recode)) {
      cat("No output table specified, recode table not written to disk\n")
  } else {
    cat(paste("Writing individual recode table to: ",ind.recode,"\n"))
    write.table(new, file=ind.recode, sep=",", row.names=FALSE, col.names=FALSE)    
  }

# Apply the new assignments  
  ind.list <- as.character(indNames(gl));
  ntr <- length(new[,1])
  for (i in 1:nInd(gl)) {
    for (j in 1:ntr) {
      if (ind.list[i]==new[j,1]) {ind.list[i] <- new[j,2]}
    }
  }
  # Assigning new populations to gl
  cat("Assigning new individual (=specimen) names\n")
  indNames(gl) <- ind.list
  
  # Remove rows flagged for deletion
  cat("Deleting individuals flagged for deletion\n")
  gl <- gl[!gl$ind.names=="delete" & !gl$ind.names=="Delete"]
  
  gl <- gl.filter.monomorphs(gl)
  
  return(gl)
  
}