# encoding: UTF-8
require 'rake'
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_billing_sisow'
  s.version     = '0.9.2'
  s.summary     = 'Spree billing integration for Sisow payment provider'
  s.description = 'Spree billing integration for Sisow iDeal/Bancontact/Sofort/Paypal payments'
  s.required_ruby_version = '>= 1.9.3'

  s.authors   = ['Sjors Baltus', 'Bèr Kessels']
  s.email     = ['gems@berk.es']
  s.homepage  = 'http://github.com/berkes/spree_billing_sisow'

  s.files     =  FileList['app/**/*', 'config/**/*', 'db/**/*', 'lib/**/*',
                          'README.md','LICENSE'].to_a

  s.test_files  = FileList['spec/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.7.0'
  s.add_dependency 'spree_frontend', '~> 3.7.0'
  s.add_dependency 'sisow', '~> 2.0'

  s.add_development_dependency 'spree_backend', '~> 3.7.0' # Needed to test the backend interface
  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_bot'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 3.5'
  s.add_development_dependency 'rspec-activemodel-mocks',  '~> 1.0'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
