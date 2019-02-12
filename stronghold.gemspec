
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "stronghold/version"

Gem::Specification.new do |spec|
  spec.name          = "stronghold"
  spec.version       = Stronghold::VERSION
  spec.authors       = ["Katherine Lynch"]
  spec.email         = ["katherly@upenn.edu"]
  spec.summary       = %q{The stronghold gem acts as middleware that interacts with Amazon Glacier through Fog}
  spec.description   = %q{The stronghold gem acts as middleware that interacts with Amazon Glacier through Fog}
  spec.license       = "Apache License 2.0"

  spec.files         = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0.11.3"
  spec.add_development_dependency "pry-byebug", "~> 3.6"

  spec.add_dependency "fog-aws", "~> 2.0"

end
