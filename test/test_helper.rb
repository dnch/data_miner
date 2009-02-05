require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'ruby-debug'
require 'data_miner'

# Always handy...
ActiveRecord::Base.logger = Logger.new("debug.log")

# We gotta shove this somewhere...
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

# And finally...
ActiveRecord::Schema.define(:version => 1) do
  create_table :nimrods do |t|
    t.integer :length
    t.decimal :price, :precision => 10, :scale => 2
    t.boolean :sold
  end
end

class ActiveRecord::Base
  include DataMiner
end


class Nimrod < ActiveRecord::Base
end
