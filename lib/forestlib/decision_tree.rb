require 'ai4r'
require 'csv'
include Ai4r::Classifiers
include Ai4r::Data

module ForestLib
  class DecisionTree
    def initialize(input_csv)
      data_set = []
      CSV.foreach(input_csv) do |row|
        data_set << row
      end
      data_labels = data_set.shift
      data_set = DataSet.new(:data_items=>data_set, :data_labels=>data_labels)
      @id3 = ID3.new.build(data_set)
    end
    
    def get_rules
      @id3.get_rules
    end
    
    def eval(input_array)
      @id3.eval input_array
    end
  end
end

# data_set = DataSet.new(:data_items=>[ ['boogie', 'N'], ['bye', 'Y'] ], :data_labels=>['hello','greeting'])
# id3 = ID3.new.build(data_set)
# puts id3.get_rules
