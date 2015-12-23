
library(methods)

source("parameters.R")

if (!exists("Agent")) {
    source("Agent.R")
}


#############################################################################
# Cohort class. A cohort is a set of agents who are the same age.

Cohort <- setRefClass("Cohort",
    fields = list(
        age="numeric",
        members="list"
    ),
    methods = list(
        initialize=function(...) {
            .self$initFields(...)
        }
    )
)

Cohort$methods(advance.age=function() age <<- age + 1)




