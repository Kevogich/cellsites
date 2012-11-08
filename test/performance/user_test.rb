require '../test_helper'
require 'rails/performance_test_help'

class UserTest < ActiveSupport::TestCase

#  fixtures :users

  def test_attr_must_not_be_empty
    user = User.new
    assert user.invalid?
    assert user.errors[:username].any?
  end

  def test_should_create_user
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_user_name
    assert_no_difference 'User.count' do
      user = create_user(:username=>nil)
      assert user.errors.on(:username)
    end
  end

  def test_should_require_password
    assert_no_difference 'User.count' do
      user = create_user(:password=>nil)
      assert user.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    assert_no_difference 'User.count' do
      user = create_user(:password_confirmation=>nil)
      assert user.errors.on(:password_confirmation)
    end
  end

  def test_should_require_same_password_confirmation
    assert_no_difference 'User.count' do
      user = create_user(:password=>'iiit123',:password_confirmation=>'iiit321')
      assert user.errors.on(:password_confirmation)
      assert user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_email
    assert_no_difference 'User.count' do
      user = create_user(:email=>nil)
      assert user.errors.on(:email)
    end
  end

  def test_should_not_allow_same_username
    assert_no_difference 'User.count' do
      user = create_user
      user1 = create_user(:name => 'sm', :email => 'admin1@example.com', :password => 'pwd', :password_confirmation => 'pwd')
      assert user1.new_record?, "#{user1.errors.full_messages.to_sentence}"
    end
  end

  def test_should_not_allow_same_email
    assert_no_difference 'User.count' do
      user = create_user
      user1 = create_user(:username => 'admin1',:name => 'sm', :email => 'admin@example.com', :password => 'pwd', :password_confirmation => 'pwd')
      assert user1.new_record?, "#{user1.errors.full_messages.to_sentence}"
    end
  end

  protected
  def create_user(options = {})
    record = User.new({:username => 'admin', :name => 'Admin', :email => 'admin@example.com', :password => 'password', :password_confirmation => 'password' }.merge(options))
    record.save
    record
  end
end
