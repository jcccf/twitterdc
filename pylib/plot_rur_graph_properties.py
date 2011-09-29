from graph_functions import *
import pickle
import matplotlib.pyplot as plt

plt.rcParams['font.size'] = 18

def plot_2(graphs, labels=['Reciprocated', 'Unreciprocated'], ylim=None, xlabel=None, ylabel=None, filename="default"):
  plt.clf()
  for graph, label in zip(graphs, labels):
    g2 = sorted(zip(*graph),key = lambda x : x[0])
    graph = zip(*g2)
    plt.plot(graph[0], graph[1], label=label)
  if ylim:
    plt.ylim(ylim)
  if xlabel:
    plt.xlabel(xlabel)
  if ylabel:
    plt.ylabel(ylabel)
  leg = plt.legend(loc='best')
  for t in leg.get_texts():
    t.set_fontsize('small')
  plt.savefig("../pydata/images/%s.eps" % filename)


# Plot proportion of rec edges and nodes on the same plot 
# for n=1000, k=10-30
# for n=300,500,1000
ps = {}
for n in [100,200,300,500,1000]:
  with open("../pydata/%d_rur_prop.txt" % n, "r") as f:
    ps[n] = pickle.load(f)

prop = ps[1000]
rec_edges = [(k,v['prop_rec_edges']) for k,v in prop.iteritems()]
rec_edges = zip(*rec_edges)
rec_nodes = [(k,v['prop_rec_nodes']) for k,v in prop.iteritems()]
rec_nodes = zip(*rec_nodes)
unr_nodes = [(k,v['prop_unr_nodes']) for k,v in prop.iteritems()]
unr_nodes = zip(*unr_nodes)
shared_nodes = [(k,v['prop_shared_nodes']) for k,v in prop.iteritems()]
shared_nodes = zip(*shared_nodes)
plot_2([rec_edges, rec_nodes, unr_nodes, shared_nodes], labels=['Edges in Rec.', 'Nodes in Rec.', 'Nodes in Unr.', 'Shared Nodes'], ylim=(0,1), xlabel=r"$k$", ylabel="Proportion", filename="proportion_edgesnodes_k")

rec_edges = [(k,v[10]['prop_rec_edges']) for k,v in ps.iteritems()]
rec_edges = zip(*rec_edges)
rec_nodes = [(k,v[10]['prop_rec_nodes']) for k,v in ps.iteritems()]
rec_nodes = zip(*rec_nodes)
unr_nodes = [(k,v[10]['prop_unr_nodes']) for k,v in ps.iteritems()]
unr_nodes = zip(*unr_nodes)
shared_nodes = [(k,v[10]['prop_shared_nodes']) for k,v in ps.iteritems()]
shared_nodes = zip(*shared_nodes)
plot_2([rec_edges, rec_nodes, unr_nodes, shared_nodes], labels=['Edges in Rec.', 'Nodes in Rec.', 'Nodes in Unr.', 'Shared Nodes'], ylim=(0,1), xlabel=r"$n$", ylabel="Proportion", filename="proportion_edgesnodes_n")


# Compare proportion in largest connected component 
# in rec and unrec graphs on the same plot for n=1000, k=10-30
# in rec and unrec graphs on the same plot for n=300,500,1000
rec, unr = {}, {}
for n in [100,200,300,500,1000]:
  with open("../pydata/%d_rec.txt" % n, "r") as f:
    rec[n] = pickle.load(f)
  with open("../pydata/%d_unr.txt" % n, "r") as f:
    unr[n] = pickle.load(f)
    
reck, unrk = rec[1000], unr[1000]
rec_cc = [(k,v['proportion_in_largestcc']) for k,v in reck.iteritems()]
unr_cc = [(k,v['proportion_in_largestcc']) for k,v in unrk.iteritems()]
rec_cc, unr_cc = zip(*rec_cc), zip(*unr_cc)
plot_2([rec_cc, unr_cc], xlabel=r"$k$", ylabel="Proportion", filename="proportion_largestcc_k")
# of nodes in largest connected component

rec_lu = [(k,v['average_clustering']) for k,v in reck.iteritems()]
unr_lu = [(k,v['average_clustering']) for k,v in unrk.iteritems()]
rec_lu, unr_lu = zip(*rec_lu), zip(*unr_lu)
plot_2([rec_lu, unr_lu], xlabel=r"$k$", ylabel="Average clustering coefficient", filename="average_clustering_k")

rec_cc = [(k,v[10]['proportion_in_largestcc']) for k,v in rec.iteritems()]
unr_cc = [(k,v[10]['proportion_in_largestcc']) for k,v in unr.iteritems()]
rec_cc, unr_cc = zip(*rec_cc), zip(*unr_cc)
plot_2([rec_cc, unr_cc], xlabel=r"$n$", ylabel="Proportion", filename="proportion_largestcc_n")
# of nodes in largest connected component

rec_lu = [(k,v[10]['average_clustering']) for k,v in rec.iteritems()]
unr_lu = [(k,v[10]['average_clustering']) for k,v in unr.iteritems()]
rec_lu, unr_lu = zip(*rec_lu), zip(*unr_lu)
plot_2([rec_lu, unr_lu], xlabel=r"$n$", ylabel="Average clustering coefficient", filename="average_clustering_n")
