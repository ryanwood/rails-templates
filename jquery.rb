# Use JQuery instead of Prototype
prototype_files = %w(prototype scriptaculous controls dragdrop effects slider).map { |f| "public/javascripts/#{f}.js" }
run "rm -f #{prototype_files.join(' ')}"
run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js > public/javascripts/jquery.js"
run "curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"