
package edu.umw.shinysim;

/** 
 * Sim.java -- Shinysim stub. This is a placeholder for a simulation, written
 * in Java (I recommend the MASON agent-based modeling toolkit; see
 * http://cs.gmu.edu/~eclab/projects/mason/) that will communicate with the R
 * Shinysim framework through files.
 *
 * @author Stephen
 */


// Don't use java.util.Random in real life! This is just an example. I
// recommend the MASON agent-based modeling toolkit, and its ec.util pacakge's
// MersenneTwisterFast class.
// import ec.util.MersenneTwisterFast;
import java.util.Random;  

import java.io.PrintWriter;
import java.io.BufferedWriter;
import java.io.FileWriter;


public class Sim {

    /** The arguments to main() are expected to be, in order:
        <ul>
        <li>0 through p-1: a total of p simulation-specific parameters</li>
        <li>p: -maxTime</li>
        <li>p+1: the max number of generations the simulation should run</li>
        <li>p+2: -simtag</li>
        <li>p+3: a large random integer, given by the calling program, to
            identify this particular dynamic running of the simulation</li>
        <li>p+4: (optional) -seed</li>
        <li>p+5: (optional) the random number generator seed to use</li>
        </ul>
     In this simple stub, p=1, and the simulation's sole parameter is a 
     multiplicative factor for the random data it spits out.
    */
    public static void main(String args[]) {

        if (args.length < 5 || 
            !args[1].equals("-maxTime") ||
            !args[3].equals("-simtag")) {
            printUsageAndQuit();
        }

        // (Standard parameters expected to be common to all Shiny Sims)
        int maxTime = Integer.valueOf(args[2]);
        long simtag = Long.valueOf(args[4]);
        long seed = System.currentTimeMillis();
        // WARNING: if you set the seed this way, you need to add "-seed seed"
        // to the args array, so that when it is passed to doLoop(), doLoop()
        // is forced to use that seed instead of making its own.
        
        // (An example parameter for this silly demo)
        double multiplicativeFactor = Double.valueOf(args[0]);

        if (args.length >= 7) {
            seed = Long.valueOf(args[6]);
        }

        Random rng = new Random(seed);
        

        // Write the parameters file to a simtag-annotated filename in the 
        // current directory.
        try {
            PrintWriter paramsFile = new PrintWriter(new BufferedWriter(
                new FileWriter("./sim_params" + simtag + ".txt")));
            paramsFile.println("seed="+seed);
            paramsFile.println("maxTime="+maxTime);
            paramsFile.println("simtag="+simtag);
            paramsFile.println("multiplicativeFactor="+multiplicativeFactor);
            paramsFile.close();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(2);
        }

        // Write the output file to standard out.
        System.out.println("period,data");
        for (int g=1; g<=maxTime; g++) {
            double nextStat = rng.nextDouble() * multiplicativeFactor;
            System.out.println(g + "," + nextStat);
            System.out.flush();
            try {
                Thread.sleep(rng.nextInt(2000));
            } catch (InterruptedException e) {
            }
        }

        /*
         * MASON users: the easiest way to run your simulation from here is:
         * 1) Have your main model class inherit from SimState (I call it
         * "Model" in the example code below)
         * 2) Make that model class a singleton, with an instance() method
         * 3) Give your main model class some public static variables that
         * represent the sim parameters, and set those (as below)
         * 4) Call doLoop on the Model directly from here, passing it a new
         * MakesSimState (as below).
         *
         * Model.PARAM_NUMBER_ONE = multiplicativeFactor;
         * Model.PARAM_NUMBER_TWO = someOtherSimSpecificParameter;
         * Model.doLoop(new MakesSimState() {
         *     public SimState newInstance(long seed, String[] args) {
         *         return Model.instance();
         *     }
         *     public Class simulationClass() {
         *         return Model.class;
         *     }
         * }, args);
         */
    }

    private static void printUsageAndQuit() {
        System.err.println("Usage: Sim multiplicativeFactor " +
            "-maxTime numGenerations " +
            "-simtag simulationTag [-seed seed].");
        System.exit(1);
    }
}
