Spree Billing Sisow
=================
[![Build Status](https://travis-ci.org/berkes/spree_billing_sisow.png)](https://travis-ci.org/berkes/spree_billing_sisow)
[![Code Climate](https://codeclimate.com/github/berkes/spree_billing_sisow.png)](https://codeclimate.com/github/berkes/spree_billing_sisow)
[![Test Coverage](https://codeclimate.com/github/berkes/spree_billing_sisow/badges/coverage.svg)](https://codeclimate.com/github/berkes/spree_billing_sisow)
[![Dependency Status](https://gemnasium.com/badges/github.com/berkes/spree_billing_sisow.svg)](https://gemnasium.com/github.com/berkes/spree_billing_sisow)

Spree Billing Integration for Sisow (Ideal / Bancontact / Sofort / Paypal) payments.
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

Author
------

Developed by [xtr3me](https://github.com/xtr3me)

[Other contributors](https://github.com/xtr3me/spree_billing_sisow/graphs/contributors)

Currently maintained by [Bèr `berkes` Kessels](http://berk.es)

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
