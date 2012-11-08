require '../test_helper'
require 'rails/performance_test_help'

class CompanyTest < ActiveSupport::TestCase

#  fixtures :users

  def test_should_create_company
    assert_difference 'Company.count' do
      company = create_company
      assert !company.new_record?, "#{company.errors.full_messages.to_sentence}"
    end
  end

#  def test_should_require_company_name
#    assert_no_difference 'Company.count' do
#      company = create_company(:name=>nil)
#      assert company.errors.on(:name)
#    end
#  end

#  def test_should_require_admin_username
#    assert_no_difference 'Company.count' do
#      company = create_company(:admin_username=>nil)
#      assert company.errors.on(:admin_username)
#    end
#  end
#
#  def test_should_require_admin_password
#    assert_no_difference 'Company.count' do
 #     company = create_company(:admin_password=>nil)
 #     assert company.errors.on(:admin_password)
 #   end
 # end
#
#  def test_should_require_email
#    assert_no_difference 'Company.count' do
#      company = create_company(:email=>nil)
#      assert company.errors.on(:email)
##    end
#  end


  protected
  def create_company(options = {})
    record = Company.new({:name => 'Test Company', :admin_username => 'testadmin', :admin_password => 'password', :contact_person => 'Test Company Admin', :email => 'admin@testcompany.com'}.merge(options))
    record.save
    record
  end
end
