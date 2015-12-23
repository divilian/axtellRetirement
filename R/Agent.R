
# Agent class. An agent is an individual who, if not already retired, will
# decide whether to retire. This is the abstract superclass of all specific
# subtypes with different retirement-decision algorithms.

library(methods)

Agent <- setRefClass("Agent",
    fields = list(
        age="numeric", 
        death.age="numeric", 
        state="character" # should be factor(c("working","retired","dead")).
    )
)

stephen <- Agent$new(age=46,death.age=72,state="working")
