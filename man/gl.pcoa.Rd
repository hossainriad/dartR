% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gl.pcoa.r
\name{gl.pcoa}
\alias{gl.pcoa}
\title{PCoA ordination (glPca)}
\usage{
gl.pcoa(gl, nfactors = 5)
}
\arguments{
\item{gl}{Name of the genlight object containing the SNP genotypes by specimen and population [required]}

\item{nfactors}{Number of dimensions to retain in the output file [default 5]}
}
\value{
An object of class glPca containing the eigenvalues, factor scores and factor loadings
}
\description{
This script takes the data on SNP genotypes for individuals and undertakes a Gower PCoa ordination using Euclidean distance and drawing upon
data in the original genlight \{adegenet\} object (entity x attribute matrix).
The script is essentially a wrapper for glPca() \{adegenet\} with default settings apart from setting parallel=FALSE and
converting the eigenvalues to percentages.
}
\examples{
pcoa <- gl.pcoa(testset.gl, nfactors=3)
}
\author{
Arthur Georges (glbugs@aerg.canberra.edu.au)
}
