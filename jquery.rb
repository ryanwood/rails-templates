# Use JQuery instead of Prototype
%w(prototype scriptaculous controls dragdrop effects slider).each do |f|
  run("rm -f public/javascripts/#{f}.js")
end
run "curl -L http://jqueryjs.googlecode.com/files/jquery-1.3.2.min.js > public/javascripts/jquery.js"
run "curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"