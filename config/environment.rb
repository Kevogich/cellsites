# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
App::Application.initialize!

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|  
  if html_tag =~ /<(label)/
    html_tag.html_safe
  else
    "#{html_tag}<br><span class='field_error_msg'>#{instance_tag.error_message.first}</span>".html_safe
  end    
end
