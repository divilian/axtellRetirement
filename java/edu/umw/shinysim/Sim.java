
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

        double multiplicativeFactor = Double.valueOf(args[0]);

        int maxTime = Integer.valueOf(args[2]);

        long simtag = Long.valueOf(args[4]);

        long seed = System.currentTimeMillis();
        
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
    }

    private static void printUsageAndQuit() {
        System.err.println("Usage: Sim multiplicativeFactor " +
            "-maxTime numGenerations " +
            "-simtag simulationTag [-seed seed].");
        System.exit(1);
    }
}
