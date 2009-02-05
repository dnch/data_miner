require 'test_helper'

class QueryAggregatesTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  setup :generate_test_data

  test "test data generation works" do
    assert_equal @number_of_records, @prices.length
    assert_equal @number_of_records, @lengths.length
    assert_equal @number_of_records, @solds.length
    assert_equal @number_of_records, Nimrod.all.length       
  end

  test "query without conditions" do    
    result_hash = Nimrod.query_aggregates do |q|
      q.sum :length
      q.count :all      
    end    
    
    expected_length = @lengths.inject { |sum, l| sum + l }
    expected_count = @number_of_records
    
    ActiveRecord::Base.logger.debug { result_hash }
    
    assert_equal expected_count, result_hash["count_all"]
    assert_equal expected_length, result_hash["sum_length"]        
  end

  protected
  def generate_test_data
    # clear out test data
    Nimrod.delete_all    
    
    # create our sample data (between 10 and 110 records)
    @number_of_records = 10 + rand(100)

    # track these so we can 
    @prices  = []
    @lengths = []
    @solds   = []

    @number_of_records.times do |x|
      @prices << (rand * 300) + 1.0
      @lengths << rand(500)
      @solds << rand(2).zero?
      
      Nimrod.create do |nimrod|
        nimrod.price = @prices.last
        nimrod.length = @lengths.last
        nimrod.sold = @solds.last
      end
    end
  end

end


