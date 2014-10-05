
library(shiny)
library(shinyIncubator)

SIM.FILES.BASE.DIR <- "/tmp"
SOURCE.DIR <- "/home/stephen/research/shinysim"
CLASSES.DIR <- "/tmp/classes"
SIM.STATS.FILE <- paste0(SIM.FILES.BASE.DIR,"/","sim_statsSIMTAG.csv")
SIM.PARAMS.FILE <- paste0(SIM.FILES.BASE.DIR,"/","sim_paramsSIMTAG.txt")
SIM.CLASS.NAME <- "edu.umw.shinysim.Sim"
JAVA.RUN.TIME.OPTIONS <- ""
REFRESH.PERIOD.MILLIS <- 500

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
#  Java simulation produces a comma-separated output file called SIM.STATS.FILE
#    which it writes to, perhaps slowly, with one line per period. The first
#    column of this .csv is called "period" and is an integer ranging from 1
#    to maxTime.
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
            # Change the colClasses argument here, if desired, to control the
            # classes used for each of the data columns.
            read.csv(sub("SIMTAG",simtag,SIM.STATS.FILE),header=TRUE,
                colClasses=c("integer", "numeric"),
                stringsAsFactors=FALSE)
        },error = function(e) return(data.frame())
        )
    }

    seed <- function() {
        get.param("seed")
    }
    
    get.param <- function(param.name) {
    
        if (!file.exists(sub("SIMTAG",simtag,SIM.PARAMS.FILE))) {
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
            #
            the.df <- read.table(sub("SIMTAG",simtag,SIM.PARAMS.FILE),
                header=FALSE,sep="=",stringsAsFactors=FALSE)
            params <<- setNames(the.df[[2]],the.df[[1]])
        }
        
        return(params[[param.name]])
    }

    observe({
        if (input$runsim < 1) return(NULL)

        isolate({
            maxTime <- input$maxTime
            if (!sim.started) {
                simtag <<- ceiling(runif(1,1,1e8))
                cat("Starting sim",simtag,"\n")
                progress <<- Progress$new(session,min=0,max=maxTime+1)
                progress$set(message="Launching simulation...",value=0)
                start.sim(input,simtag)
                progress$set(message="Initializing simulation...",value=1)
                sim.started <<- TRUE
            }
        })

        output$log <- renderText(HTML(paste0("<b>Log output:</b><br/>",
            "sim #",simtag,"<br/>",
            "seed: ",seed(),"<br/>")))

        sim.stats.df <- sim.stats()
        if (nrow(sim.stats.df) > 0) {
            progress$set("Running simulation...",
                detail=paste(max(sim.stats.df$period),"of",maxTime,
                    "periods"),
                value=1+max(sim.stats.df$period))
            if (max(sim.stats.df$period) == maxTime) {
                progress$set("Done.",value=1+maxTime)
                sim.started <<- FALSE
                progress$close()
            } else {
                # If the simulation is running, but not finished, check
                # its progress again in a little bit.
                invalidateLater(REFRESH.PERIOD.MILLIS,session)
            }
        } else {
            # If the simulation isn't running yet, check its progress 
            # again in a little bit.
            invalidateLater(REFRESH.PERIOD.MILLIS,session)
        }
    })

    start.sim <- function(input,simtag) {
        setwd(SIM.FILES.BASE.DIR)
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

    output$analysis1Plot <- renderPlot({
        # A simple plot, showing the field called "data" in the .csv versus
        # the period number. Put here any awesome analysis you like.
        if (input$runsim < 1) return(NULL)
        sim.stats.df <- sim.stats()
        if (nrow(sim.stats.df) > 0) {
            the.plot <- ggplot(sim.stats.df,aes(x=period,y=data)) + 
                geom_line(color="blue") + 
                scale_x_continuous(limits=c(1,isolate(input$maxTime)),
                                    breaks=1:isolate(input$maxTime)) +
                expand_limits(y=0)
                labs(title="Data",x="Sim period")
            print(the.plot)
        }
        # Recreate this plot in a little bit.
        invalidateLater(REFRESH.PERIOD.MILLIS,session)
    })

    kill.all.sims <- function() {
        system(paste("pkill -f",SIM.CLASS.NAME))
    }
})
