
library(methods)

source("parameters.R")

source("Agent.R")


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

Cohort$methods(fill=function(num.agents) {
    members <<- vector("list", num.agents)
    for (i in 1:num.agents) {
        members[[i]] <<- generate.agent(age=age)
    }
})

Cohort$methods(num.agents=function() length(members))



print.Cohort <- function(x, ...) {
    print(paste0("A cohort of ", length(x$members), " ", x$age,"-year olds"))
    invisible(x)
}

