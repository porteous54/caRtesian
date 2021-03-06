% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/selection.R
\name{tournamentSelection}
\alias{tournamentSelection}
\title{tournamentSelection}
\usage{
tournamentSelection(population, tournamentSize)
}
\arguments{
\item{population}{the population to sample}

\item{tournamentSize}{the number of samples to take}
}
\value{
the individual with the best fitness
}
\description{
Performs Tournament Selection on the population by taking a sample of the
population (can be duplicates) and returning the individual with the best
fitness.
}
