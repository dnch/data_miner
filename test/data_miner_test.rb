require 'test_helper'

class DataMinerTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  setup :generate_test_data

  test "test data generation works" do
    assert_equal @number_of_records, @prices.length
    assert_equal @number_of_records, @lengths.length
    assert_equal @number_of_records, @solds.length
    assert_equal @number_of_records, Nimrod.all.length       
  end

  test "query without conditions" do    
    result_hash = Nimrod.mine do
      sum :length
      count :all      
    end    
    
    expected_length = @lengths.inject { |sum, l| sum + l }
    expected_count = @number_of_records
      
    assert_equal expected_count, result_hash[:count_all]
    assert_equal expected_length, result_hash[:sum_length]        
  end
  
  test "query with conditions" do
    Nimrod.create(:length => 182455, :price => 0.0)
    Nimrod.create(:length => 182455, :price => 50.0)
    Nimrod.create(:length => 182455, :price => 100.0)    

    result_hash = Nimrod.mine(:conditions => ["length = ?", 182455]) do
      count :all
      avg :price
      min :price
      max :price
    end
    
    puts result_hash.inspect
    
    assert_equal 3, result_hash[:count_all]
    assert_equal 50, result_hash[:avg_price]
    assert_equal 0, result_hash[:min_price]
    assert_equal 100, result_hash[:max_price]
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


