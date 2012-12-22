source :rubygems

# Core
#gem 'bundler', '~> 1.0.7'
gem 'rails', '3.0.4'
gem 'rake', '0.9.2'
gem 'meta_where'
gem 'mysql2', '0.2.7'
gem 'devise', "1.4.8"
gem 'nifty-generators', '>= 0.4.0'
gem 'jquery-rails', '>= 1.0.12'
gem 'will_paginate', '~> 3.0.pre2'
gem 'paperclip', '~> 2.7.0'
gem 'acts_as_commentable'
#gem "acts_as_state_machine", "~> 2.2.0"

gem 'spreadsheet', '0.6.5.4'
gem 'roo', '1.9.3'
gem 'rubyzip'
gem 'nokogiri'
gem 'google-spreadsheet-ruby'
gem 'pdfkit'
gem 'activerecord-import', '0.2.6'
gem 'deep_cloneable', '1.2.4'
gem 'alchemist'
gem 'minimization'

group :test do
  gem 'cucumber-rails'
end

if (%w(production staging).include? ENV['RACK_ENV']) || (ENV['USER'] =~ /^repo\d+$/)  # kludge to exclude on Heroku
  # heroku specific gems here
else
  group :development, :test do

    #Misc
    gem 'hirb'

    # Deploy
    gem "heroku", "1.13.7"
    gem 'capistrano'
    gem 'capistrano-ext'

    # Testing/BDD
    gem 'capybara'
    gem 'database_cleaner'
    gem 'rspec-rails'
    gem 'autotest'
    gem 'launchy'
    #gem 'factory_girl_rails', :git => 'git://github.com/thoughtbot/factory_girl_rails.git'
  end
end
