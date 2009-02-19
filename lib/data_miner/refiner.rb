module DataMiner
  class Refiner  
    attr_accessor :result_label, :after_proc, :field, :function
    
    def initialize(function, args)
      @function = function.to_s
      @field    = args.first
      @options  = args[1] || {}
      
      @result_label = @options[:as] || default_result_label
      @after_proc   = @options[:after] || default_after_proc
    end
    
    # nothing more than syntactic sugar for function_catcher
    def to_hash
      { @result_label.to_s => self }
    end
    
    # foo_sum, etc
    def default_result_label
      "#{@function}_#{@field}"
    end
    
    # 99.9% of the time we're going to be dealing with numbers, so we may as well just default to it, given that AR gives us strings.
    def default_after_proc
      lambda { |r| r.to_f }
    end
    
    # TODO - incorpoate AR's sql sanitising, just in case...
    def sql_fragment
      "#{@function.upcase}(#{@field}) as #{@result_label.to_s}"
    end
  end
end