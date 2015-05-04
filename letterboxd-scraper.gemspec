# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'letterboxd/scraper/version'

Gem::Specification.new do |spec|
  spec.name          = "letterboxd-scraper"
  spec.version       = Letterboxd::Scraper::VERSION
  spec.authors       = ["Koen Romers"]
  spec.email         = ["info@koenromers.com"]

  spec.summary       = "Just a Letterboxd scraper."
  spec.description   = "Since Letterboxd.com doesn't have an API yet, here is a gem to scrape the data."
  spec.homepage      = "https://github.com/koenoe/letterboxd-scraper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "nokogiri"

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
end
