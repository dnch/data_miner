Introduction to DataMiner
=========================
DataMiner is an ActiveRecord plugin which simplifies creating complex data-probing queries using a familiar, rails-like syntax.

    results = Nimrod.mine do
      sum :price
      count :all
    end
  
This would result in the following query being executed:

    SELECT SUM(price) as sum_price, COUNT(*) as count_all FROM nimrods;

If the query only has one result, the *mine* function returns a `Hash` with a set of pairs, one for each field in the query. The above example would return the following, given 54 rows each with a price of 9.95:

    { :sum_price => 537.5, :count => 54 }

Function calls are captured using `method_missing`, so any functions present in your chosen database system may be used:

    results = Nimrod.mind do
      stddev :price
      avg :length
      fictional_function :year
    end
  
DataMiner will also accept a `:group` key in its arguments. It will pass the value of `:group` as the `GROUP BY` clause in the query.  The field(s) included in the group parameter are automatically included in the result set:

    results = Nimrod.mine(:group => "year") do
      sum :price
      count :all
    end
  
    => [{ :year => 2005, :sum_price => 537.5, :count => 54 }, { :year => 2007, :sum_price => 134.55, :count => 352 }]

If the query results in more than one row, an `Array` containing the corresponding `Hash` for each row is returned.

Because `mine` uses the `find` method of `ActiveRecord::Base` to query the database, any options that can be passed to `find` can be passed to `mine`:

    results = Nimrod.mine(:conditions => ["length > ?", 50], :group => "year, length") do
      sum :price
      count :all
    end

Function Arguments
------------------
DataMiner currently supports two arguments that can be passed to each function call: `:as` and `:after`

`:as` allows you to override the default naming convention of each result field:

    results = Nimrod.mine do
      sum :price, :as => "total_price_in_set"
    end

    # => SELECT SUM(price) as total_price_in_set, COUNT(*) as count_all FROM nimrods;

By default, DataMiner will attempt to convert strings to numeric using `to_f`. To override this functionality, pass a block to `:after`:

    results = Nimrod.mine do
      sum :price, :as => "total_price_in_cents", :after => lambda { |x| x.to_f * 100 }
    end



Legals
------
Copyright (c) 2009 Daniel Cheail, released under the MIT license
