source "https://rubygems.org/"

gemspec

group :development do
  gem 'warbler', :git => 'git://github.com/jruby/warbler.git', :ref => 'ce3ce4df137504822e4cbb9399dee7e7dd767c44'
  gem 'rubygems-tasks', :git => 'git://github.com/postmodern/rubygems-tasks.git'
end

platforms :jruby do
  gem 'jruby-openssl' if ((defined? JRUBY_VERSION) && (JRUBY_VERSION.split('.')[1].to_i < 7))
end

platforms :ruby_18 do
  gem 'oniguruma'
end
