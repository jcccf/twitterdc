import networkx as nx

def graph_properties(filename, directed=False):
  # Read in rec as undirected graph
  if directed:
    G=nx.read_edgelist(filename, nodetype=int, create_using=nx.DiGraph())
  else:
    G=nx.read_edgelist(filename, nodetype=int, create_using=nx.Graph())

  props = {}

  # Calculate number of edges
  props['num_edges'] = G.number_of_edges()

  # Calculate number of nodes
  props['num_nodes'] = len(G)

  # Calculate largest connected component
  largest_component = nx.connected_component_subgraphs(G)[0]
  props['size_largestcc'] = len(largest_component)
  props['proportion_in_largestcc'] = float(len(largest_component)) / len(G)

  # Calculate clustering coefficient
  props['average_clustering'] = nx.average_clustering(G)

  # Calculate diameter of largest connected component
  # props['diameter'] = nx.diameter(largest_component)
  
  return props
  
def graph_nodes(filename):
  G=nx.read_edgelist(filename, nodetype=int, create_using=nx.Graph())
  return G.nodes()