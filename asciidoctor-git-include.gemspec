Gem::Specification.new do |s|
  s.name          = "asciidoctor-git-include"
  s.version       = "1.3.0"
  s.authors       = ["Jakub Zalas"]
  s.email         = ["jakub@zalas.pl"]
  s.description   = %q{Asciidoctor extension for including files from Git repositories}
  s.summary       = %q{Fetch files from Git repositories while rendering asciidoc files.}
  s.homepage      = "https://github.com/jakzal/asciidoctor-git-include"
  s.license       = "MIT"
  s.files         = "lib/asciidoctor-git-include.rb"
  s.add_runtime_dependency "asciidoctor", "~> 2.0"
end
