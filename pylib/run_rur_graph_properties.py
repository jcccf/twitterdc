from graph_functions import *
import pickle
from optparse import OptionParser

parser = OptionParser()
parser.add_option("-n", type="int", dest="n", default=1000, help="n, minimum # of messages sent per user")
parser.add_option("-l", "--klower", type="int", dest="klower", default=10, help="Lower bound on k")
parser.add_option("-u", "--kupper", type="int", dest="kupper", default=30, help="Upper bound on k")
(options, args) = parser.parse_args()

N = options.n
LOW = options.klower
HIGH = options.kupper+1

print "Using n=%d, k1=%d, k2=%d..." % (N,LOW,HIGH-1)

# Read in rec as undirected graph
print "Calculating for reciprocated graphs..."
rec = {}
for i in range(LOW,HIGH):
  filename = "../data/%d_%03d_recn.txt" % (N,i)
  rec[i] = graph_properties(filename)
with open("../pydata/%d_rec.txt" % N, "w") as f:
  pickle.dump(rec,f)

# Read in unrec as undirected graph
# TODO unrec as DIRECTED graph?
print "Calculating for unreciprocated graphs..."
unr = {}
for i in range(LOW,HIGH):
  filename = "../data/%d_%03d_unr.txt" % (N,i)
  unr[i] = graph_properties(filename)
with open("../pydata/%d_unr.txt" % N, "w") as f:
  pickle.dump(unr,f)
  
# Calculate number of nodes in each
print "Comparing..."
prop = {}
for i in range(LOW,HIGH):
  total_edges = rec[i]['num_edges'] + unr[i]['num_edges']
  
  # Calculate total # of unique nodes
  ugn = graph_nodes("../data/%d_%03d_unr.txt" % (N,i))
  assert(len(ugn) == unr[i]['num_nodes'])
  rgn = graph_nodes("../data/%d_%03d_recn.txt" % (N,i))
  assert(len(rgn) == rec[i]['num_nodes'])
  unique_nodes = list(set(ugn) | set(rgn))
  shared_nodes = list(set(ugn) & set(rgn))
  total_nodes = len(unique_nodes)
  
  prop[i] = {}
  prop[i]['prop_rec_edges'] = float(rec[i]['num_edges']) / total_edges
  prop[i]['prop_unr_edges'] = float(unr[i]['num_edges']) / total_edges
  prop[i]['prop_rec_nodes'] = float(rec[i]['num_nodes']) / total_nodes
  prop[i]['prop_unr_nodes'] = float(unr[i]['num_nodes']) / total_nodes
  prop[i]['prop_shared_nodes'] = float(len(shared_nodes)) / total_nodes
with open("../pydata/%d_rur_prop.txt" % N, "w") as f:
  pickle.dump(prop,f)