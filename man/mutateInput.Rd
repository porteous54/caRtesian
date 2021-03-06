% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/selection.R
\name{mutateInput}
\alias{mutateInput}
\title{mutateInput}
\usage{
mutateInput(solution, chromoID, functionNodeStructure)
}
\arguments{
\item{solution}{the solution containing the nodes}

\item{chromoID}{the node to be given new inputs}

\item{functionNodeStructure}{the parameters used when creating functionNodes}
}
\value{
the new input values
}
\description{
Generates a random new input chromoID for the node given by chromoID
}
