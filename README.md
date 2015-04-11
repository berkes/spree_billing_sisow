Spree Billing Sisow
=================
[![Build Status](https://travis-ci.org/xtr3me/spree_billing_sisow.png)](https://travis-ci.org/xtr3me/spree_billing_sisow)
[![Code Climate](https://codeclimate.com/github/xtr3me/spree_billing_sisow.png)](https://codeclimate.com/github/xtr3me/spree_billing_sisow)
[![Coverage Status](https://coveralls.io/repos/xtr3me/spree_billing_sisow/badge.png)](https://coveralls.io/r/xtr3me/spree_billing_sisow)
[![Dependency Status](https://gemnasium.com/xtr3me/spree_billing_sisow.png)](https://gemnasium.com/xtr3me/spree_billing_sisow)

Spree Billing Integration for Sisow (Ideal / Bancontact / Sofort) payments.
This Gem is currently being build and tested, and is not yet released for use in production systems

Installation
------------

Add spree_billing_sisow to your Gemfile:

```ruby
gem 'spree_billing_sisow'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_billing_sisow:install
```

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_billing_sisow/factories'
```

Copyright (c) 2013 Sjors Baltus, released under the New BSD License
