% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/population.R
\name{generateFunctionNodes}
\alias{generateFunctionNodes}
\title{generateFunctionNodes}
\usage{
generateFunctionNodes(startID, nrows, ncols, levelsBack, functionSet)
}
\arguments{
\item{startID}{the starting chromoID}

\item{nrows}{the number of rows required in the chromosome}

\item{ncols}{the number of columns required in the chromosome}

\item{levelsBack}{the number of columns back that each column can access}

\item{functionSet}{the functions to choose from}
}
\value{
a data frame containing the function nodes
}
\description{
Generates a data frame containing a row for each function node required. The
number of rows is equal to the product of the nrows and ncols parameters.
Each row is given a unique ID (chromoID) which is unique within the entire
chromosome. The value field of each row is set as NA initially. The funcID
field is the ID a random function chosen from the functionSet. The input
field is a vector of valid nodes to use as arguments to the function field.
}
