require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'

include ::Asciidoctor

class GitIncludeMacro < Asciidoctor::Extensions::IncludeProcessor
  use_dsl

  def handles? target
    (target.start_with? 'git@')
  end

  def process doc, reader, target, attributes
    target.slice! "git@"
    repository = attributes.fetch('repository', '.')
    revision = attributes.fetch('revision', 'HEAD')

    cmd = %(git -C #{repository} show #{revision}:#{target})
    content = %x(#{cmd})

    reader.push_include content, target, target, 1, attributes
    reader
  end
end

Asciidoctor::Extensions.register do
  include_processor GitIncludeMacro
end
