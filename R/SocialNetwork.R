
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
            cat("Removing element",i,"!\n")
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
    
