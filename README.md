Spree Filter Products
=====================

This extension adds filter products form taxon optyons to left sidebar

Installation
------------

Add spree_filter_products to your Gemfile:

For 3.0.3 versions of spree.

```ruby
gem 'spree_filter_products'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_filter_products:install
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
require 'spree_filter_products/factories'
```

Contributing
------------

1. Fork the repo.
2. Clone your repo.
3. Run `bundle install`.
4. Run `bundle exec rake test_app` to create the test application in `spec/test_app`.
5. Make your changes.
6. Ensure specs pass by running `bundle exec rspec spec`.
7. Submit your pull request.