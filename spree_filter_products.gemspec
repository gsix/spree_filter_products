# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_filter_products'
  s.version     = '0.0.1'
  s.summary     = 'Filter Products in Spree'
  s.description = 'This extension adds filter products form taxon optyons to left sidebar'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Genesix'
  s.email     = 'admin@genesix.ru'
  s.homepage  = 'http://genesix.ru'
  s.license   = "MIT"

  s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.0.3'
end
