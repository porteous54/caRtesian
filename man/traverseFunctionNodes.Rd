% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fitness.R
\name{traverseFunctionNodes}
\alias{traverseFunctionNodes}
\title{traverseFunctionNodes}
\usage{
traverseFunctionNodes(functionNodes, nodesUsed, chromoID)
}
\arguments{
\item{functionNodes}{the functionNode structure}

\item{nodesUsed}{a boolean vector signifying if a node was used}

\item{chromoID}{the chromoID of the starting node}
}
\value{
a boolean vector signifying the nodes used
}
\description{
Traverses through the functionNode structure starting at chromoID
and then recursively running on each of the nodes inputs.
}
