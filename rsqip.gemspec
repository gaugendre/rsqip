unless defined? Rsqip::VERSION
  $LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
  require 'rsqip/version'
end

Gem::Specification.new do |s|
  s.name        = 'rsqip'
  s.version     = Rsqip::VERSION
  s.platform    = Gem::Platform::RUBY
  s.date        = '2017-11-15'

  s.summary     = 'ruby sqip'
  s.description = 'Ruby port of SVG LQIP'

  s.authors     = ['Guilhem Augendre']
  s.email       = 'guilhem@augendre.fr'

  s.files       = Dir['README.md', 'UNLICENSE.TXT', 'lib/**/*.rb']

  s.homepage    = 'http://rubygems.org/gems/rsqip'
  s.license     = 'UNLICENSE'

  s.add_dependency 'dimensions', '~> 1.3.0'

  s.add_developement_dependency 'rubocop'
  s.add_developement_dependency 'rake', '~> 12.3.0'
  s.add_developement_dependency 'minitest', '~> 5.10.3'
end
