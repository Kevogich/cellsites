require '../test_helper'
require 'rails/performance_test_help'

class RoleTest < ActiveSupport::TestCase

#  fixtures :users

  def test_should_create_role
    assert_difference 'Role.count' do
      role = create_role
      assert !role.new_record?, "#{role.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference 'Role.count' do
      role = create_role(:name=>nil)
      assert role.errors.on(:name)
    end
  end

  def test_should_require_identifier
    assert_no_difference 'Role.count' do
      role = create_role(:identifier=>nil)
      assert role.errors.on(:identifier)
    end
  end

  protected
  def create_role(options = {})
    record = Role.new({:name => 'some Role',:identifier => 'somerole'}.merge(options))
    record.save
    record
  end
end
