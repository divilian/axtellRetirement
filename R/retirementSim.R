
library(methods)

source("parameters.R")

source("Agent.R")
source("Cohort.R")
source("SocialNetwork.R")


##############################################################################
# Cohorts

# The all.cohorts global variable is an indexed list of Cohort objects.
initialize.cohorts <- function() {
    all.cohorts <<- vector("list", max(SPAWN.AGE.RANGE))
    for (age in 1:max(SPAWN.AGE.RANGE)) {
        all.cohorts[[age]] <<- Cohort$new(age=age)
    }
    for (age in SPAWN.AGE.RANGE) {
        all.cohorts[[age]]$fill(AGENTS.PER.COHORT)
    }
}

advance.cohorts <- function() {
    all.cohorts <<- c(Cohort$new(age=1),all.cohorts[1:(max(SPAWN.AGE.RANGE)-1)])
}


##############################################################################
# SocialNetworks

initialize.social.networks <- function() {
    lapply(all.cohorts, function(cohort) {
        lapply(cohort$members, function(agent) {
            agent$social.network <- SocialNetwork$new(owner=agent)
        })
    })
}



##############################################################################
# Main.
retirement <- function() {

    initialize.cohorts()   # (which also initializes agents.)
    initialize.social.networks()

}
