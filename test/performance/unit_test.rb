require '../test_helper'
require 'rails/performance_test_help'

class UnitTest < ActiveSupport::TestCase

#  fixtures :users

  def test_should_create_unit
    assert_difference 'Unit.count' do
      unit = create_unit
      assert !unit.new_record?, "#{unit.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference 'Unit.count' do
      unit = create_unit(:name=>nil)
      assert unit.errors.on(:name)
    end
  end


  protected
  def create_unit(options = {})
    record = Unit.new({:name => 'someUnit'}.merge(options))
    record.save
    record
  end
end
