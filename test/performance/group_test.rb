require '../test_helper'
require 'rails/performance_test_help'

class GroupTest < ActiveSupport::TestCase

#  fixtures :users

  def test_should_create_group
    assert_difference 'Group.count' do
      group = create_group
      assert !group.new_record?, "#{group.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference 'Group.count' do
      group = create_group(:name=>nil)
      assert group.errors.on(:name)
    end
  end


  protected
  def create_group(options = {})
    record = Group.new({:name => 'someTitle'}.merge(options))
    record.save
    record
  end
end
