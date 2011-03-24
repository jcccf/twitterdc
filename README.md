TwitterDC
=========

**Author**:       Justin Cheng
**Copyright**:    2010-2011

Synopsis
--------
A set of ruby scripts designed to analyze graph data.

Requirements
------------
Gems - ai4r

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

### Building the SCC Charts

1. Run Plot1 for the various stages
  i.  Stage 1 calculates the # of unique nodes and depends on Atm2
  ii. Stage 2 plots the SCC proportions and depends on Atm3

### Prediction Graphs

1. Run Pred1 for the various stages in order
  i.  Stage 1 calculates the degree count and builds the edge graph and depends on Atm1
  ii. Stage 2 does prediction based on the generated reciprocated graphs and depends on Atm2
  iii.Stage 3 generates predicted rec/unrec graphs
  iv. Stage 4 builds the SCC for the predicted unrec graph