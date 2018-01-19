source 'https://rubygems.org'

gem 'rake'

platforms :ruby do
  gem 'sqlite3'
end

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbcsqlite3-adapter'
end

group :test do
  gem 'activerecord', (ENV['RAILS_VERSION'] || ['~> 4.1'])
  gem 'actionmailer', (ENV['RAILS_VERSION'] || ['~> 4.1'])
  gem 'coveralls', :require => false
  gem 'rspec', '~> 2.14'
  gem 'simplecov', :require => false
end

platforms :rbx do
  gem 'json'
  gem 'rubinius-coverage'
  gem 'rubysl'
end

gemspec
