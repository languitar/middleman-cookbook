$LOAD_PATH.push File.expand_path('lib', __dir__)

Gem::Specification.new do |s|
  s.name        = 'middleman-cookbook'
  s.version     = '0.0.2'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Johannes Wienke']
  s.email       = ['languitar@semipol.de']
  s.homepage    = 'https://www.semipol.de'
  s.summary     = 'Builds a cookbook from structured data'
  s.description = 'Uses paprika-compatible YAML files'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  # The version of middleman-core your extension depends on
  s.add_runtime_dependency('middleman-core', ['>= 4.2.1'])

  # Additional dependencies
  s.add_runtime_dependency('json_schemer', '>= 0.1.7')
end
