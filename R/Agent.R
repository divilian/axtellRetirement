
library(methods)

source("parameters.R")

#############################################################################
# Agent class. An agent is an individual who, if not already retired, will
# decide whether to retire. This is the abstract superclass of all specific
# subtypes with different retirement-decision algorithms.

Agent <- setRefClass("Agent",
    fields = list(
        age="numeric", 
        death.age="numeric", 
        state="character" # should be factor(c("working","retired","dead")).
    ),
    methods = list(
        initialize=function(...) {
            if (is.null(list(...)$age)) {
                stop("Agent not initialized with age.")
            }
            age <<- list(...)$age
            death.age <<- sample(DEATH.AGE.RANGE[1]:DEATH.AGE.RANGE[2],1)
            state <<- "working"
        }
    )
    
)

Agent$methods(possibly.retire=function() {
    stopifnot(state=="working")
    if (.self$decide.whether.to.retire()) {
        state <<- "retired"
        return(TRUE)
    } else {
        return(FALSE)
    }
})

Agent$methods(decide.whether.to.retire=function() {
    stop("Abstract method decide.whether.to.retire() called.")
})





#############################################################################
# RandomAgent class. Each time it is queried, a RandomAgent chooses to retire
# with fixed probability.

RandomAgent <- setRefClass("RandomAgent",
    contains="Agent",
    fields = list(
        retirement.probability="numeric"
    ),
    methods = list(
        initialize=function(retirement.probability=0, ...) { 
            callSuper(...)
            retirement.probability <<- retirement.probability
        }
    )
)

RandomAgent$methods(decide.whether.to.retire=function() {
    return(runif(1) < retirement.probability)
})




#############################################################################
# RationalAgent class. A RationalAgent always retires as soon as possible.

RationalAgent <- setRefClass("RationalAgent",
    contains="Agent",
    fields = list(),
    methods = list(
        initialize=function(...) { 
            callSuper(...)
        }
    )
)

RationalAgent$methods(decide.whether.to.retire=function() {
    return(age >= AGE.OF.RETIREMENT.ELIGIBILITY)
})


