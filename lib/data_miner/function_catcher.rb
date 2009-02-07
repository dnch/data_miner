module DataMiner
  class FunctionCatcher    
    def initialize(parent_class, args)
      @caught_functions   = {}
      @parent_class       = parent_class
      @args_for_find_call = args
    end

    # We're expecting people to call this in the following format: sum(:field_name, :as => "booobobo")
    def method_missing(sym, *args)            
      # Double-check to see that we've actually included a field that we recognise as being part of the analysis    
      if (args.empty? || !@parent_class.column_names.include?(args.first.to_s)) && args.first.to_s != 'all'
        throw MissingOrUnknownFieldNameException.new
      else  
        refiner = Refiner.new(sym, args)              
        @caught_functions[refiner.result_label.to_sym] = refiner
      end    
    end

    # TODO - refactor so it will return a single hash if the results are one row, or an array if multiples.
    def go    
      # Build our SQL from each Refiner
      select_sql_fragment = @caught_functions.values.map { |r| r.sql_fragment }.join(", ")

      # make our call...
      raw_results = @parent_class.find(:all, @args_for_find_call.merge(:select => select_sql_fragment))

      # run our post-search procs on the results
      result_array = raw_results.map do |r|
        
        # transform each AR:B instance into a simple hash that we've post-processed
        r.attributes.inject({}) do |memo, pair|          
          key = pair.first.to_sym
          val = pair.last
                
          memo.merge(key => @caught_functions[key].after_proc.call(val))
        end
      end

      # if we've only got one result in the array, return it
      result_array.length > 1 ? result_array : result_array.first
    end
  end  
end
