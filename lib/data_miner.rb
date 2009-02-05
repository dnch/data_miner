require 'data_miner/function_catcher'
require 'data_miner/refiner'

module DataMiner
  module ClassMethods    

    #
    # PUT DOC HERE
    #
    def mine(args = {}, &block)
      # does exactly what it says it does...
      fc = DataMiner::FunctionCatcher.new(self, args)      
      fc.instance_eval(&block)
      fc.go
    end
  end
  
  module InstanceMethods    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
  
  class MissingOrUnknownFieldNameException < Exception; end
end