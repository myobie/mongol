require "./lib/mongol"

Gem::Specification.new do |s|
  s.name = 'mongol'
  s.version = Mongol::VERSION
  s.platform = Gem::Platform::RUBY

  s.summary = 'Super-lightweight Object Document Modelling wrapper for mongo'
  s.description = 'A super-lightweight ODM for mongo supporing models, indexes, associations, and embedded documents'

  s.require_paths = ['lib']
  s.files = ['README.markdown', 'Rakefile', 'mongol.gemspec', 'LICENSE']
  s.files += ['lib/mongol.rb'] + Dir['lib/mongol/**/*.rb']
  s.test_files = Dir['text/**/*.rb']
  s.has_rdoc = false
  s.authors = ['Nathan Herald']
  s.email = 'nathan@myobie.com'
  s.homepage = 'http://github.com/myobie/mongol'
  s.add_dependency 'mongo', ['~>1.1.5']
end
