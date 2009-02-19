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

  test "multi-row result set" do
    Nimrod.create(:length => 282455, :price => 0.0)
    Nimrod.create(:length => 282455, :price => 50.0)
    Nimrod.create(:length => 282455, :price => 100.0)

    Nimrod.create(:length => 913943, :price => 200.0)
    Nimrod.create(:length => 913943, :price => 200.0)
    Nimrod.create(:length => 913943, :price => 200.0)

    Nimrod.create(:length => 1321313, :price => 400.0)
    Nimrod.create(:length => 1321313, :price => 300.0)
    Nimrod.create(:length => 1321313, :price => 200.0)

    Nimrod.create(:length => 54848408, :price => 8.0)
    Nimrod.create(:length => 54848408, :price => 6.0)
    Nimrod.create(:length => 54848408, :price => 4.0)

    results = Nimrod.mine(:conditions => ["length >= ?", 282455], :group => "length", :order => "length asc") do
      sum :price
      avg :price
      count :all
    end
    
    assert_equal 4, results.length
    assert_equal 282455, results[0][:length]
    assert_equal 150.0, results[0][:sum_price]
    assert_equal 50.0, results[0][:avg_price]    
    assert_equal 3, results[0][:count_all]

    assert_equal 913943, results[1][:length]
    assert_equal 600.0, results[1][:sum_price]
    assert_equal 200.0, results[1][:avg_price]    
    assert_equal 3, results[1][:count_all]

    assert_equal 1321313, results[2][:length]
    assert_equal 900.0, results[2][:sum_price]
    assert_equal 300.0, results[2][:avg_price]    
    assert_equal 3, results[2][:count_all]

    assert_equal 54848408, results[3][:length]
    assert_equal 18.0, results[3][:sum_price]
    assert_equal 6.0, results[3][:avg_price]    
    assert_equal 3, results[3][:count_all]
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
      max :price, :as => "el_maximo"
      max :price, :as => "el_maximo_grande", :after => lambda { |x| x.to_f * 60 }
      max :price, :as => "el_maximo_grande_proc", :after => Proc.new { |x| x.to_f * 60 }
    end

    assert_equal 3, result_hash[:count_all]
    assert_equal 50, result_hash[:avg_price]
    assert_equal 0, result_hash[:min_price]
    assert_equal 100, result_hash[:max_price]
    assert_equal 100, result_hash[:el_maximo]
    assert_equal 6000, result_hash[:el_maximo_grande]
    assert_equal 6000, result_hash[:el_maximo_grande_proc]
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


