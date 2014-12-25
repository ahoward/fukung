## fukung.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "fukung"
  spec.version = "2.0.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "fukung"
  spec.description = "perhaps the most important ruby code EVAAARRR! gets random images from http://fukung.net."

  spec.files = ["a.rb", "bin", "bin/fukung", "fukung.gemspec", "lib", "lib/fukung.rb", "Rakefile", "README"]
  spec.executables = ["fukung"]
  
  spec.require_path = "lib"

  spec.has_rdoc = true
  spec.test_files = nil

# spec.add_dependency 'lib', '>= version'
  spec.add_dependency 'launchy'

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "http://github.com/ahoward/fukung"
end
