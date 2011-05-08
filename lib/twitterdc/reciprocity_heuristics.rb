require_relative 'twitterdc'
require_relative '../forestlib/processor'
include TwitterDc
include ForestLib
require_relative 'rh_base'
require_relative 'rh_degree'
require_relative 'rh_messages'
require_relative 'rh_messages_per_degree'
require_relative 'rh_mutual_absolute'
require_relative 'rh_mutual_jaccard'
require_relative 'rh_mutualin_adamic'
require_relative 'rh_outdegree_per_indegree'
require_relative 'rh_katz'
require_relative 'rh_pagerank'
require_relative 'rh_preferential_attachment'

# c = ReciprocityHeuristics::RootedPagerank.constants(Constants.new("abc",500,10,30))
# e = {1 => [2,5], 5=>[3], 2 => [3,4]}
# x = ReciprocityHeuristics::KatzNStepDecision.new(c,e)
# puts x.result(1,3)