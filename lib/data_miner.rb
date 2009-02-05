module DataMiner
  module ClassMethods    
    def mine(args = {}, &block)

      # does exactly what it says it does...
      fc = FunctionCatcher.new(self)      
      fc.instance_eval(&block)
      fc.
    end
  end
  
  module InstanceMethods    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

  # result_set = Foo.find_calculations(:conditions => ["active = ?", true]) do
  #   sum :field_one, :as => "sum_of_field_one"
  #   count :field_four
  #   max :field_one
  #   min :field_one
  #   mean :field_eight
  # end
  # 
  # result_set[:sum_of_field_one] # => 53
  # result_set[:field_four_count] # => 11
  # result_set[:field_one_max] # => 1535
  # result_set[:field_two_max] # => 144
  # result_set[:field_eight_mean] # => 94.314
 
  class FunctionCatcher    
    def initialize(parent_class)
      @caught_functions = []
      @parent_class = parent_class
    end
      
    # We're expecting people to call this in the following format: sum(:field_name, :as => "booobobo")
    def method_missing(sym, *args)            
          
      field_name = args[0].to_s
      call_args  = args[1] || {}
      
      # Double-check to see that we've actually included a field that we recognise as being part of the analysis    
      if (args.empty? || !@parent_class.column_names.include?(field_name)) && field_name != 'all'
        throw MissingOrUnknownFieldNameException.new
      end
      
      function_name = sym.to_s.upcase
      field_used = (field_name == 'all' ? "*" : field_name)
      as_name = call_args[:as] || "#{function_name}_#{field_name}"
      
      @caught_functions << "#{sym.to_s.upcase}(#{field_used}) AS #{as_name.to_s.downcase}"
    end
    
    def to_select_string
      @caught_functions.join(", ")
    end
  end
  
  class MissingOrUnknownFieldNameException < Exception; end
end