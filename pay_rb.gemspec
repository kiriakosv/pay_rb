# frozen_string_literal: true

require_relative "lib/pay_rb/version"

Gem::Specification.new do |spec|
  spec.name = "pay_rb"
  spec.version = PayRb::VERSION
  spec.authors = ["Kiriakos Velissariou"]
  spec.email = ["kiriakos@hey.com"]

  spec.summary = "Ruby client for banks"
  spec.description = "A Ruby wrapper for banks' REST API that provides a simple interface for managing banking operations."
  spec.homepage = "https://github.com/kiriakosv/pay_rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kiriakosv/pay_rb"
  spec.metadata["changelog_uri"] = "https://github.com/kiriakosv/pay_rb/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "faraday", "~> 2.12"
  spec.add_dependency "activesupport", "~> 7.2"
  spec.add_development_dependency 'webmock', '~> 3.24'


  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
