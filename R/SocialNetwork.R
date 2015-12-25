
library(methods)

source("Agent.R")
source("Cohort.R")


#############################################################################
# SocialNetwork class. A "social network" is simply a list of other agents
# upon whom a particular agent depends for influence. It is effectively a
# directed graph; Y being in X's social network does not imply that X is in
# Y's.

SocialNetwork <- setRefClass("SocialNetwork",
    fields = list(
        owner="Agent",
        extent="numeric",
        influencers="list"
    )
)

SocialNetwork$methods(get.possible.influencers = function() {
    ages.of.possible.influencers <- 
        (owner$age - extent):(owner$age + extent)
    poss.i <- unique(unlist(
                lapply(all.cohorts[ages.of.possible.influencers],
                function(cohort) cohort$members)))
    # Remove myself from this list.
    # (Stupidest technique ever. What's the right way to do this?)
    for (i in length(poss.i):1) {
        if (identical(poss.i[[i]], owner)) {
            poss.i <- poss.i[-i]
        }
    }
    poss.i
})
    
SocialNetwork$methods(initialize=function(...) {
    if (is.null(list(...)$owner)) {
        cat("SocialNetwork not initialized with owner.\n")
    } else {
        owner <<- list(...)$owner
        extent <<- sample(SOCIAL.NETWORK.EXTENT.RANGE, 1)
        num.influencers <- sample(SOCIAL.NETWORK.SIZE.RANGE,1)
        possible.influencers <- get.possible.influencers()
        influencers <<- sample(possible.influencers,
            min(c(num.influencers,length(possible.influencers))))
    }
})

SocialNetwork$methods(get.number.in.states = function(states) {
    sum(sapply(influencers, function(agent) agent$state %in% states))
})

SocialNetwork$methods(get.number.eligible.to.retire = function() {
    return(get.number.in.states(c("working","retired")))
})

SocialNetwork$methods(get.number.retired = function() {
    return(get.number.in.states("retired"))
})

SocialNetwork$methods(fraction.retired.of.eligible = function() {
    return(get.number.retired() / get.number.eligible.to.retire())
})

print.SocialNetwork <- function(x, ...) {
    print(paste0("A social network of ", length(x$influencers), 
        " influencing agents (extent ", x$extent, ")"))
    invisible(x)
}
