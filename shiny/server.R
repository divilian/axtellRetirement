
library(shiny)
library(shinyIncubator)

SOURCE.DIR <- "/home/stephen/research/shinysim"
CLASSES.DIR <- "/tmp/classes"
SIM.STATS.FILE <- "/tmp/sim_statsSIMTAG.csv"
SIM.PARAMS.FILE <- "/tmp/sim_paramsSIMTAG.txt"
SIM.CLASS.NAME <- "edu.umw.shinysim.Sim"
JAVA.RUN.TIME.OPTIONS <- ""

LIBS <- c("mason.17.jar")

CLASSPATH <- paste(
    paste("..","lib",LIBS,sep="/",collapse=":"),
    CLASSES.DIR,sep=":")


# Assumptions:
#  UI has a "maxTime" input with number of years/periods/generations for sim
#    to run.
#  UI has a "seedType" radio which can be set to "specific" or "rand". If
#    "specific" then a "seed" input will be set to contain an integer seed.
#  Sim has other parameters, which it will write as key value pairs in
#    a plain-text file called SIM.PARAMS.FILE once the sim starts. Each of 
#    these parameters, other than simtag, has an identically named input in 
#    the UI.
#  Java simulation takes these parameters on command-line, with maxTime
#    preceded immediately by "-maxTime" and simtag by "-tag".
shinyServer(function(input,output,session) {

    sim.started <- FALSE
    progress <- NULL
    simtag <- 0     # A hashtag we'll create for each particular sim run.
    params <- NULL

    sim.stats <- function() {
        if (!file.exists(sub("SIMTAG",simtag,SIM.STATS.FILE))) {
            return(data.frame())
        }
        tryCatch({
            read.csv(sub("SIMTAG",simtag,SIM.STATS.FILE),header=TRUE,
                stringsAsFactors=FALSE)
        },error = function(e) return(data.frame())
        )
    }

    seed <- function() {
        get.param("seed")
    }
    
    get.param <- function(param.name) {
    
        if (!file.exists(sub("SIMTAG",simtag,".txt"))) {
            return(NA)
        }
        if (is.null(params)) {
            #
            # Assume an equals-separated, one-line-per-parameter format, a la:
            # 
            # seed=4592
            # maxTime=100
            # simtag=932345
            # velocity=12.5
            # numGenerations=100
            #
            the.df <- read.table(sub("SIMTAG",simtag,".txt"),header=FALSE,
                sep="=",stringsAsFactors=FALSE)
            params <<- setNames(the.df[[2]],the.df[[1]])
        }
        
        return(params[[param.name]])
    }

    observe({
        if (input$runsim < 1) return(NULL)

        isolate({
            if (!sim.started) {
                simtag <<- ceiling(runif(1,1,1e8))
                cat("Starting sim",simtag,"\n")
                progress <<- Progress$new(session,min=0,max=input$maxTime)
                progress$set(message="Launching simulation...",value=0)
                start.sim(input,simtag)
            }

        })
    })

    start.sim <- function(input,simtag) {
        # setwd("Do we need to be anywhere special to run this?")
        isolate({
            if (!file.exists(CLASSES.DIR)) {
                system(paste("mkdir",CLASSES.DIR))
                system(paste("find",SOURCE.DIR,"-name \"*.java\" ",
                    "> /tmp/javasourcefiles.txt"))
                system(paste("javac -d",CLASSES.DIR,
                    "@/tmp/javasourcefiles.txt"))
                system("rm /tmp/javasourcefiles.txt")
            }
            system(paste("nice java -classpath ",CLASSPATH,
                JAVA.RUN.TIME.OPTIONS,SIM.CLASS.NAME,
                # Add other simulation parameters here
                input$simParam1,
                "-maxTime",input$maxTime,
                "-simtag",simtag,
                ifelse(input$seedType=="specific",
                                            paste("-seed",input$seed),
                                            ""),
                ">",sub("SIMTAG",simtag,SIM.STATS.FILE),"&"))
        })
    }

    kill.all.sims <- function() {
        system(paste("pkill -f",SIM.CLASS.NAME))
    }
})
