
library(methods)

source("parameters.R")

source("Agent.R")
source("Cohort.R")


##############################################################################
# Cohorts

# The all.cohorts global variable is an indexed list of Cohort objects.
all.cohorts <- vector("list", max(SPAWN.AGE.RANGE))
for (age in 1:SPAWN.AGE.RANGE[2]) {
    all.cohorts[[age]] <- Cohort$new(age=age)
}
for (age in SPAWN.AGE.RANGE[1]:SPAWN.AGE.RANGE[2]) {
    all.cohorts[[age]]$fill(AGENTS.PER.COHORT)
}

advance.cohorts <- function() {
    all.cohorts <<- c(Cohort$new(age=1),all.cohorts[1:(SPAWN.AGE.RANGE[2]-1)])
}
