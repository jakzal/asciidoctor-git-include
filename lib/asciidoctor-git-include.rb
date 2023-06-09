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
    lines = attributes.fetch('lines', '')
    as_diff = attributes.value?('diff') || attributes.key?('diff')
    diff_revision = attributes.fetch('diff', "#{revision}~1")

    cmd = %(git -C #{repository} show #{revision}:#{target})
    if (as_diff)
      cmd = %(git -C #{repository} diff #{diff_revision}:#{target} #{revision}:#{target})
    end
    content = %x(#{cmd})

    content = process_line_selection(content, lines) unless lines == ""

    reader.push_include content, target, target, 1, attributes
    reader
  end

  # inspired by https://github.com/tkfu/asciidoctor-github-include/blob/410e0079b2300596ca2b16c94c23c63459e6d0f8/lib/asciidoctor-github-include.rb#LL79C7-L79C29
  def process_line_selection content, lines
    snipped_content = []
    selected_lines = []
    text = content.split(/\n/)

    lines.split(/[,;]/).each do |linedef|
      if linedef.include?('..')
        from, to = linedef.split('..', 2).map {|it| it.to_i }
        to = text.length if to == -1
        selected_lines.concat ::Range.new(from, to).to_a
      else
        selected_lines << linedef.to_i
      end
    end
    selected_lines.sort.uniq.each do |i|
      snipped_content << text[i-1]
    end
    snipped_content
  end
end

Asciidoctor::Extensions.register do
  include_processor GitIncludeMacro
end
