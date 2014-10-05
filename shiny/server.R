
# Shiny Sim. A template for displaying an analysis of a Java simulation (often
# agent-based) in a Shiny Web-based interface.
#
# Stephen Davies, Ph.D. -- University of Mary Washington
# 10/5/2014
#
# At a minimum, you will want to change everything marked CHANGE in this file
# and in ui.R. You will often also want to change things marked OPTIONAL.
#
# Assumptions:
#  The UI (defined in ui.R) has a "maxTime" input with the total number of 
#    years/periods/generations for the sim to run.
#  UI has a "seedType" radio button which can be set to "specific" or "rand".
#    If "specific," then a "seed" input will be set to contain an integer seed.
#  The sim has other parameters, many of which will probably be passed to it
#    on the command-line, and which it will write as key value pairs in a 
#    plain-text file called SIM.PARAMS.FILE once the sim starts. Each of these 
#    parameters (other than simtag, which Shiny Sim generates on its own) has
#    an identically named input in the UI.
#  The Java simulation's command-line parameters include maxTime preceded 
#    immediately by "-maxTime" and simtag preceded immediately by "-tag".
#  As it runs, the sim produces a comma-separated output file called 
#    SIM.STATS.FILE which it writes to, perhaps slowly, with one line per 
#    period. The first column of this .csv is called "period" and is an 
#    integer ranging from 1 to maxTime.

library(shiny)
library(shinyIncubator)


# -------------------------------- Constants ---------------------------------
SIM.FILES.BASE.DIR <- "/tmp"

# CHANGE: The full path of your project directory. Any .java file that appears
# in this directory hierarchy will be compiled as part of the simulation.
SOURCE.DIR <- "/home/stephen/research/shinysim"

CLASSES.DIR <- "/tmp/classes"

SIM.STATS.FILE <- paste0(SIM.FILES.BASE.DIR,"/","sim_statsSIMTAG.csv")

SIM.PARAMS.FILE <- paste0(SIM.FILES.BASE.DIR,"/","sim_paramsSIMTAG.txt")

# CHANGE: The package/classname of the main() Java class in your sim.
SIM.CLASS.NAME <- "edu.umw.shinysim.Sim"

JAVA.RUN.TIME.OPTIONS <- ""

# OPTIONAL: The rate (number of milliseconds between refreshes) at which the
# web app will read the simulator's output file for progress to update plots
# and such.
REFRESH.PERIOD.MILLIS <- 500

# OPTIONAL: Any Java libraries needed by the simulation.
LIBS <- c("mason.17.jar")

CLASSPATH <- paste(
    paste("..","lib",LIBS,sep="/",collapse=":"),
    CLASSES.DIR,sep=":")



# ------------------------- The Shiny Sim server -----------------------------
shinyServer(function(input,output,session) {

    sim.started <- FALSE
    progress <- NULL
    simtag <- 0     # A hashtag we'll create for each particular sim run.
    params <- NULL


    # Return a data frame containing the most recent contents of the 
    # SIM.STATS.FILE.
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


    # Return the seed, as recorded in the SIM.PARAMS.FILE.
    seed <- function() {
        get.param("seed")
    }
    

    # Return the value of the named parameter, as recorded in the 
    # SIM.PARAMS.FILE. Often (but not always) this will have been passed to
    # the sim via command-line argument, after being retrieved from the UI.
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


    # Shiny Observer to start the simulation when the button is pressed.
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


    # Start a new instance of the Java simulation.
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
                # CHANGE: Add any other simulation parameters required on the
                # Java command-line here.
                input$simParam1,
                "-maxTime",input$maxTime,
                "-simtag",simtag,
                ifelse(input$seedType=="specific",
                                            paste("-seed",input$seed),
                                            ""),
                ">",sub("SIMTAG",simtag,SIM.STATS.FILE),"&"))
        })
    }


    # CHANGE: put any graphics commands to produce a visual analysis of the
    # simulation's output here.
    output$analysis1Plot <- renderPlot({
        # This boilerplate is a simple plot, showing the field called "data" 
        # in the .csv versus the period number.
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


    # Nuke any sims that are still currently running.
    kill.all.sims <- function() {
        system(paste("pkill -f",SIM.CLASS.NAME))
    }
})
