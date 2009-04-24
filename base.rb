# Sourcescape base template
template_path = '/Users/ryanwood/rails-templates'

git :init

run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
file '.gitignore', <<CODE
log/\\*.log
log/\\*.pid
db/\\*.db
db/\\*.sqlite3
db/schema.rb
tmp/\\*\\*/\\*
.DS_Store
doc/api
doc/app
config/database.yml
CODE

# Move the index
run "mv public/index.html public/index2.html"

load_template "#{template_path}/jquery.rb"
load_template "#{template_path}/shoulda.rb"
load_template "#{template_path}/settings.rb"

# Handle Errors
plugin 'exception_notifier', :git => 'git://github.com/rails/exception_notification.git', :submodule => true
gsub_file 'app/controllers/application_controller.rb', /class ApplicationController < ActionController::Base/ do |match|
  "#{match}\n  include ExceptionNotifiable"
end
initializer "exceptions.rb", "ExceptionNotifier.exception_recipients = %w(ryan.wood@gmail.com)"

# gem 'mislav-will-paginate'
# gem 'rubyist-aasm'

gem 'haml'
run('haml --rails .')
generate :nifty_layout, "--haml"

rakefile "bootstrap.rake", <<CODE
  namespace :app do
    task :bootstrap do
    end
  
    task :seed do
    end
  end
CODE

load_template "#{template_path}/authentication.rb"

gsub_file 'app/controllers/application_controller.rb', /#\s*(filter_parameter_logging :password)/, '\1'

git :submodule => "init" 
git :add => '.'
git :commit => "-a -m 'Initial commit'"