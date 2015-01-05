# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_billing_sisow'
  s.version     = '0.1.0'
  s.summary     = 'Spree billing integration for Sisow payment provider'
  s.description = 'Spree billing integration for Sisow iDeal /Bancontact / Sofort payments'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Sjors Baltus'
  s.email     = 'spree_gems@sjorsbaltus.nl'
  s.homepage  = 'http://github.com/xtr3me/spree_billing_sisow'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.3.0'
  s.add_dependency 'spree_frontend', '~> 2.3.0'
  s.add_dependency 'sisow', '~> 1.5'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.2'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
