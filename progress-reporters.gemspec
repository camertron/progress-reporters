$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'progress-reporters/version'  

Gem::Specification.new do |s|
  s.name     = "progress-reporters"
  s.version  = ::ProgressReporters::VERSION
  s.authors  = ["Cameron Dutro"]
  s.email    = ["camertron@gmail.com"]
  s.homepage = "http://github.com/camertron"

  s.description = s.summary = "Callback-oriented way to report the progress of a task."

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.require_path = 'lib'
  s.files = Dir["{lib,spec}/**/*", "Gemfile", "History.txt", "README.md", "Rakefile", "rosette-core.gemspec"]
end
