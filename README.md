TwitterDC
=========

**Author**:       Justin Cheng
**Copyright**:    2010-2011

Synopsis
--------
A set of ruby scripts designed to analyze graph data.

ForestLib
---------
A set of classes which allow different graph-theoretic properties to be calculated, and also helper classes to parse source files.

TwitterDc
---------
A set of Twitter-specific classes to specifically analyze Twitter data.

### In main,

1. Run Atm1 to find the people who sent more than N messages to each other, and build the filtered graphs
2. Run Atm2 to see if more than k messages were sent both ways (reciprocated) or more than k messages sent one way but no messages the other way (unreciprocated)
3. Run Atm3 to build strongest connected component sizes for the unreciprocated graphs
4. Run Atm4 to test agreement between the degree prediction and the actual graphs built

### Building the SCC Charts

1. Run Plot1 for the various stages

### Prediction Graphs

1. Run PRED1 for the various stages