# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jekyll-cloudinary-uploads/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-cloudinary-uploads"
  spec.version       = Jekyll::CloudinaryUploads::VERSION
  spec.authors       = ["Cathy Wise"]

  spec.summary       = %q{jekyll plugin to generate html snippets for embedding cloudinary image uploads}
  spec.description   = %q{jekyll plugin to generate html snippets for embedding cloudinary image uploads}
  spec.homepage      = "https://github.com/lupiter/jekyll-cloudinary-uploads"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'jekyll'
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
end