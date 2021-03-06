SPEC = Gem::Specification.new do |s|
  # identify the gem
  s.name = "sequel_container"
  s.version = "1.2.0"
  s.author = "S. Brent Faulkner"
  s.email = "brentf@unwwwired.net"
  s.homepage = "http://github.com/sbfaulkner/sequel_container"
  # platform of choice
  s.platform = Gem::Platform::RUBY
  # description of gem
  s.summary = "contained documents (i.e. attachments) for sequel models"
  s.files = %w(lib/sequel_container.rb MIT-LICENSE Rakefile README.markdown sequel_container.gemspec test/sequel_container_test.rb test/data/bio.html test/data/bio.txt test/data/logo.gif)
  s.require_path = "lib"
  s.test_file = "test/sequel_container_test.rb"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README.markdown"]
  s.add_dependency "sequel"
  # s.rubyforge_project = "sequel_container"
end
