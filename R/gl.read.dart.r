#' Import SNP data from DArT and convert to  genlight \{agegenet\} format (gl)
#'
#' DaRT provide the data as a matrix of entities (individual turtles) across the top and
#' attributes (SNP loci) down the side in a format that is unique to DArT. This program
#' reads the data in to adegenet format (genlight) for consistency with
#' other programming activity. The script or the data may require modification as DArT modify their
#' data formats from time to time.
#'
#' gl.read.dart() opens the data file (csv comma delimited) and skips the first n=topskip lines. The script assumes
#' that the next line contains the entity labels (specimen ids) followed immediately by the SNP data for the first locus.
#' It reads the SNP data into a matrix of 1s and 0s,
#' and inputs the locus metadata and specimen metadata. The locus metadata comprises a series of columns of values for
#' each locus including the essential columns of AlleleID, SNP, SnpPostion and the desirable variables REpAvg and AvgPIC.
#' Refer to documentation provide by DArT for an explanation of these columns.
#'
#' The specimen metadata provides the opportunity
#' to reassign specimens to populations, and to add other data relevant to the specimen. The key variables are id (specimen identity
#' which must be the same and in the same order as the DArTSeq file, each unique), pop (population assignment), lat (latitude, optional)
#' and lon (longitude, optional). id, pop, lat, lon are the column headers in the csv file. Other optional columns can be added.
#'
#' The SNP matrix, locus names (constructed from the AlleleID, SNP and SnpPosition to be unique), locus metadata, specimen names,
#' specimen metadata are combined into a genlight object. Refer to the genlight documentation (Package adegenet) for further details.
#'
#' @param datafile -- name of csv file containing the DartSeq data in 2-row format (csv) [required]
#' @param topskip -- number of rows to skip before the header row (containing the specimen identities [required]
#' @param nmetavar -- number of columns containing the locus metadata (e.g. AlleleID, RepAvg) [required]
#' @param nas -- missing data character [default "-"]
#' @param ind.metafile -- name of csv file containing metadata assigned to each entity (individual) [default NULL]
#' @return An object of class ("genlight") containing the SNP data, and locus and individual metadata
#' @author Arthur Georges (glbugs@aerg.canberra.edu.au)
#' @export
#' @examples
#' \dontrun{
#' gl <- gl.read.dart(datafile="SNP_DFwt15-1908_scores_2Row.csv", topskip=6, 
#' nmetavar=16, nas="-", ind.metafile="metadata.csv" )
#' }

gl.read.dart <- function(datafile, topskip, nmetavar, nas="-", ind.metafile=NULL) {

cat("This script is soon to be replaced\n")
x <- "This script is soon to be replaced\n"

  return <- x

}
