# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'gb_dispatch/version'

Gem::Specification.new do |spec|
  spec.name = 'gb_dispatch'
  spec.version = GBDispatch::VERSION
  spec.authors = ['Kacper Kawecki']
  spec.email = ['kacper@geniebelt.com']
  spec.summary = %q{GCD emulation for ruby}
  spec.description = %q{Allows to dispatch block of code for queues}
  spec.homepage = 'https://github.com/GenieBelt/gb-dispatch'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0")
  spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'celluloid', '~> 0.15.2'
  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0'
end
