require '../test_helper'
require 'rails/performance_test_help'

class TitleTest < ActiveSupport::TestCase

#  fixtures :users

  def test_should_create_title
    assert_difference 'Title.count' do
      title = create_title
      assert !title.new_record?, "#{title.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_name
    assert_no_difference 'Title.count' do
      title = create_title(:name=>nil)
      assert title.errors.on(:name)
    end
  end


  protected
  def create_title(options = {})
    record = Title.new({:name => 'someTitle'}.merge(options))
    record.save
    record
  end
end
