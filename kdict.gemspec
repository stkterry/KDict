
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "kdict/version"

Gem::Specification.new do |spec|
  spec.name          = "kdict"
  spec.version       = Kdict::VERSION
  spec.authors       = ["Steven K Terry"]
  spec.email         = ["stkterry@gmail.com"]

  spec.summary       = %q{KDict allows you to quickly create powerful Keyword-Argument Dictionaries to automate input validation.}
  spec.description   = %q{KDict allows you to quickly create powerful Keyword-Argument Dictionaries.  Each
                          entry can be used to validate a user's input against it, and is built from a
                          generic type defintion (*typedef*) and a unique structure (*struct*).

                          With the included *typedefs* users can create simple to complex validaters in
                          just a single line of code.

                          Examples avaible here in the README don't offer up the full scope of usefulness,
                          so take the time to look at the example documentation and perhaps run a few of
                          them yourself.}
  #spec.homepage      = "https://github.com/stkterry/KDict"

  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
