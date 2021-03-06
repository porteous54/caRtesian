#' muLambdaStrategy
#'
#' Runs the Mu + Lambda Evolutionary Strategy. Mu is set as 1 and Lambda can be
#' changed through the lambda parameter. Mu is the number of parents and Lambda
#' is the number of offspring to generate.
#'
#' @param population the population to be evolved
#' @param lambda the number of offspring to generate
#' @param functionNodeStructure the parameters used when creating functionNodes
#'
#' @return a new population containing the parent used and the offspring
#' @export
#'
muLambdaStrategy <- function(population, lambda, functionNodeStructure) {

  #Extract the fittest individual
  parent <- sortPopulation(population)[[1]]

  offspring <- vector(mode = "list", length = lambda)

  for (i in 1:lambda) {

    offspring[[i]] <- pointMutation(parent, functionNodeStructure)

  }

  return(c(list(parent), offspring))
}

#' tournamentSelectionStrategy
#'
#' Runs Tournament Selection and returns a new population generated from the
#' solution Tournament Selection produced.
#'
#' @param population the population to be evolved
#' @param tournamentSize the number of samples to take
#' @param functionNodeStructure the parameters used when creating functionNodes
#'
#' @return a new population containing the parent used and the offspring
#' @export
#'
tournamentSelectionStrategy <- function(population, tournamentSize,
                                        functionNodeStructure) {

  #Get an individual to use as a parent
  parent <- tournamentSelection(population, tournamentSize)[[1]]

  offspring <- vector(mode = "list", length = tournamentSize)

  for (i in 1:tournamentSize) {

    offspring[[i]] <- pointMutation(parent, functionNodeStructure)

  }

  return(c(list(parent), offspring))
}

#' tournamentSelection
#'
#' Performs Tournament Selection on the population by taking a sample of the
#' population (can be duplicates) and returning the individual with the best
#' fitness.
#'
#' @param population the population to sample
#' @param tournamentSize the number of samples to take
#'
#' @return the individual with the best fitness
#' @export
#'
tournamentSelection <- function(population, tournamentSize) {

  #Choose tournamentSize individuals from the population (can be duplicates)
  chosenIndividuals <- sample(population, size = tournamentSize, replace = TRUE)

  #Find the index of the lowest fitness value
  bestIndex <- which.min(sapply(chosenIndividuals, "[[", "fitness"))

  #Return the best indiviual found
  return(chosenIndividuals[bestIndex])
}

#' pointMutation
#'
#' Peforms point mutation on the solution. It changes up to 5% of the genes
#' and can change either the function used, or the inputs used.
#'
#' @param solution the solution to be mutated
#' @param functionNodeStructure the parameters used when creating functionNodes
#'
#' @return the solution after mutation
#'
pointMutation <- function(solution, functionNodeStructure) {

  #Mutate 10% of the genes
  maxGenesToMutate <- ceiling(0.1 * (nrow(solution$functionNodes) +
                                        nrow(solution$outputNodes))) * 3

  #Randomly choose how many genes to change
  numGenesToMutate <- sample(0:maxGenesToMutate, size = 1)


  #Get the chromoIDs of the nodes that can be mutated
  functionNodeIDs <- solution$functionNodes$chromoID
  outputNodeIDs <- solution$outputNodes$chromoID
  mutableChromoIDs <- c(functionNodeIDs, outputNodeIDs)

  #Randomly choose the nodes to mutate (can choose same node multiple times)
  nodesToMutate <- sample(mutableChromoIDs, size = numGenesToMutate,
                          replace = TRUE)

  for (i in nodesToMutate) {

    #If the node is a functionNode and we want to mutate the function
    if (is.functionNode(solution, i) && sample(0:1, size = 1) == 0) {
      #Mutate the function
      solution <- mutateFunction(solution, i, functionNodeStructure)

    } else {
      #Mutate the nodes inputs
      mutation <- mutateInput(solution, i, functionNodeStructure)

      if (is.functionNode(solution, i)) {
        #Get the index of the node to be mutated
        nodeChanged <- which(solution$functionNodes$chromoID == i)
        solution$functionNodes$inputs[[nodeChanged]] <- mutation
      } else {
        #Get the index of the node to be mutated
        nodeChanged <- which(solution$outputNodes$chromoID == i)
        solution$outputNodes$inputs[[nodeChanged]] <- mutation
      }
    }
  }

  #Reset the fitness value
  solution$fitness <- Inf

  return(solution)
}

#' mutateInput
#'
#' Generates a random new input chromoID for the node given by chromoID
#'
#' @param solution the solution containing the nodes
#' @param chromoID the node to be given new inputs
#' @param functionNodeStructure the parameters used when creating functionNodes
#'
#' @return the new input values
#'
mutateInput <- function(solution, chromoID, functionNodeStructure) {

  #Get the chromoIDs from each data frame
  inputNodeRange <- solution$inputNodes$chromoID
  functionNodeRange <- solution$functionNodes$chromoID

  #If the node to change is an outputNode
  if (is.outputNode(solution, chromoID)) {
    #Set the new input as a random node
    newInputs <- sample(c(inputNodeRange, functionNodeRange), size = 1)
  } else {
    #Get the chromoIDs of the nodes that are in range
    functionNodeRange <- getValidInputs(chromoID,
                                        functionNodeRange,
                                        functionNodeStructure)

    #Get the number of inputs to the functionNode
    index <- which(solution$functionNodes$chromoID == chromoID)
    numInputs <- length(unlist(solution$functionNodes[index, ]$inputs))

    #Randomly generate input chromoIDs
    newInputs <- sample(c(inputNodeRange, functionNodeRange),
                        size = 1)

    if (numInputs == 2) {
      #Change either the first or second input
      inputToKeep <- sample(1:numInputs, size = 1)
      if (inputToKeep == 1) {
        newInputs <- c(solution$functionNodes[index, ]$inputs[[1]][1],
                       newInputs)
      } else {
        newInputs <- c(newInputs,
                       solution$functionNodes[index, ]$inputs[[1]][2])
      }
    }
  }

  return(newInputs)
}

#' mutateFunction
#'
#' Generates a random new funcID for the node given by chromoID. Where the new
#' function has a different number of inputs than the current function, new
#' inputs are generated or removed as fit
#'
#' @param solution the solution containing the nodes
#' @param chromoID the node to be given a new function
#' @param functionNodeStructure the parameters used when creating functionNodes
#'
#' @return the solution after mutation
#'
mutateFunction <- function(solution, chromoID, functionNodeStructure) {

  #Get the index of the node to be mutated
  nodeChanged <- which(solution$functionNodes$chromoID == chromoID)

  funcSet <- functionNodeStructure$functionSet

  #Randomly choose a new function
  chosenFunc <- sample(1:nrow(funcSet), size = 1)
  solution$functionNodes[nodeChanged, ]$funcID <- chosenFunc

  #Get the arity of the new function
  arity <- funcSet[chosenFunc, ]$arity

  #Get the inputs currently used
  oldInput <- unlist(solution$functionNodes[nodeChanged, ]$inputs)

  if (length(oldInput) < arity) {
    #Need to add another input

    #Get the chromoIDs from functionNodes data frame
    functionNodeRange <- solution$functionNodes$chromoID

    #Get the chromoIDs of the nodes that are in range
    functionNodeRange <- getValidInputs(chromoID,
                                        functionNodeRange,
                                        functionNodeStructure)

    #Get the chromoIDs of the inputNodes
    inputNodeRange <- solution$inputNodes$chromoID

    #Randomly generate an input chromoID
    newInput <- sample(c(inputNodeRange, functionNodeRange), size = 1)

    solution$functionNodes$inputs[[nodeChanged]] <- c(oldInput, newInput)

  } else if (length(oldInput) > arity ) {
    #Need to remove an input

    #Choose a random input to keep
    inputToKeep <- sample(oldInput, size = 1)

    #Remove the other input
    solution$functionNodes$inputs[[nodeChanged]] <- c(inputToKeep)

  }

  return(solution)
}
