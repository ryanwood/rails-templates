# Sourcescape base template
template_path = '/Users/ryanwood/rails-templates'
rspec = yes?("Do you want to use RSpec for testing?")

# Testing
if rspec
  gem "rspec", :env => :test, :lib => false
  gem "rspec-rails", :env => :test, :lib => false
else
  gem "mocha", :env => :test
end
  
gem "factory_girl", :env => :test, :source => "http://gemcutter.org"
gem "shoulda", :env => :test, :source => "http://gemcutter.org"
  
gem "formtastic", :source => "http://gemcutter.org"
gem "haml"
run('haml --rails .')

git :init

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
file '.gitignore', <<CODE
log/*.log
db/*.db
db/*.sqlite3
db/schema.rb
tmp/**/*
.DS_Store
doc/api
doc/app
config/database.yml
CODE

# Move the index
run "mv public/index.html public/index2.html"

# Use jQuery
if yes?("Use jQuery?")
  load_template "#{template_path}/jquery.rb"
end

generate :nifty_layout, "--haml --sass"
generate :nifty_config
generate :rspec if rspec

if yes?("Do you want to add Clearance Authentication?")
  gem "clearance",
    :source  => 'http://gemcutter.org',
    :version => '0.8.3'
  generate :clearance
end

# if rspec
#   generate :nifty_authentication, "--haml --shoulda"
# else
#   generate :nifty_authentication, "--haml --rspec"
# end

# Handle Errors
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true
gsub_file 'app/controllers/application_controller.rb', /class ApplicationController < ActionController::Base/ do |match|
  "#{match}\n  include ExceptionNotifiable"
end
initializer "exceptions.rb", "ExceptionNotifier.exception_recipients = %w(ryan.wood@gmail.com)"

rakefile "bootstrap.rake", <<CODE
  namespace :app do
    task :bootstrap do
    end
  end
CODE

gsub_file 'app/controllers/application_controller.rb', /#\s*(filter_parameter_logging :password)/, '\1'

git :submodule => "init" 
git :commit => "-a -m 'Initial commit'"