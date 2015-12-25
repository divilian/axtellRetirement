
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
        state="character", # should be factor(c("working","retired","dead")).
        social.network="envRefClass", # avoid infinite recursion "bug"
        printable.type="character"
    ),
    methods = list(
        initialize=function(...) {
            if (is.null(list(...)$age)) {
                age <<- 0
            } else {
                age <<- list(...)$age
            }
            death.age <<- sample(DEATH.AGE.RANGE,1)
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

print.Agent <- function(x, ...) {
    print(paste0(x$age,"-year old ",x$state," ", x$printable.type, 
        " (will die at ", x$death.age,")"))
    invisible(x)
}




#############################################################################
# RandomAgent class. Each time it is queried, a RandomAgent chooses to retire
# with fixed probability.

RandomAgent <- setRefClass("RandomAgent",
    contains="Agent",
    fields = list(
        retirement.prob="numeric"
    ),
    methods = list(
        initialize=function(retirement.prob=RANDOM.AGENTS.RET.PROB, ...) { 
            callSuper(...)
            retirement.prob <<- retirement.prob
            printable.type <<- "RandomAgent"
        }
    )
)

RandomAgent$methods(decide.whether.to.retire=function() {
    return(runif(1) < retirement.prob)
})




#############################################################################
# RationalAgent class. A RationalAgent always retires as soon as possible.

RationalAgent <- setRefClass("RationalAgent",
    contains="Agent",
    fields = list(),
    methods = list(
        initialize=function(...) { 
            callSuper(...)
            printable.type <<- "RationalAgent"
        }
    )
)

RationalAgent$methods(decide.whether.to.retire=function() {
    return(age >= AGE.OF.RETIREMENT.ELIGIBILITY)
})



#############################################################################
# ImitativeAgent class. An ImitativeAgent decides to retire based on whether
# the fraction of eligible retirees in its SocialNetwork that are retired is
# above its imitation threshold.

ImitativeAgent <- setRefClass("ImitativeAgent",
    contains="Agent",
    fields = list(imitation.threshold="numeric"),
    methods = list(
        initialize=function(...) { 
            callSuper(...)
            imitation.threshold <<- IMITATION.THRESHOLD  # homogeneous
            printable.type <<- "ImitativeAgent"
        }
    )
)

ImitativeAgent$methods(decide.whether.to.retire=function() {
    return(social.network$fraction.retired.of.eligible() > imitation.threshold)
})



#############################################################################
# Factory method for generating agents.

agent.types <- c(rational=RationalAgent, imitative=ImitativeAgent,
    random=RandomAgent)

generate.agent <- function(age=0) {
    probabilities <- cumsum(AGENT.FREQUENCIES)
    class <- agent.types[[which(runif(1) < probabilities)[1]]]
    class$new(age=age)
}
