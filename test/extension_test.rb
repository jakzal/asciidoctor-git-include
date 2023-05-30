require_relative 'test-helper'

class ExtensionTest < Minitest::Test

  context 'Attributes' do

    test 'it includes a file from the current git repository in the HEAD revision by default' do
      input = <<-EOS
include::git@test/fixtures/readme.adoc[]
      EOS

      output = render_embedded_string input

      assert_match(/This file remains in the repository\./, output)
    end

    test 'it includes a file in specified revision' do
      input = <<-EOS
include::git@test/fixtures/only-in-repo.adoc[revision=1c2568efed7378acf8040e43932f79433b9ca302]
      EOS

      output = render_embedded_string input

      assert_match(/This file was added and then removed from the repository\./, output)
    end

    test 'it includes a file from the specified repository path' do
      dir = given_file_committed_to_fresh_repo("chapter01.adoc")

      input = <<-EOS
include::git@chapter01.adoc[repository=#{dir}]
      EOS

      output = render_embedded_string input

      assert_match(/Other repo\./, output)
    end
  end

  def given_file_committed_to_fresh_repo(file_name)
    dir = Dir.mktmpdir("asciidoctor-git-include-tests-", "/tmp")
    ENV['GIT_AUTHOR_NAME'] = "Test"
    ENV['GIT_AUTHOR_EMAIL'] = "test@example.com"
    ENV['GIT_COMMITTER_EMAIL'] = "test@example.com"
    at_exit {
      ENV.delete('GIT_AUTHOR_NAME')
      ENV.delete('GIT_AUTHOR_EMAIL')
      ENV.delete('GIT_COMMITTER_EMAIL')
      FileUtils.remove_entry(dir)
    }
    cmd = %(git init -q #{dir} && echo 'Other repo.' > #{dir}/#{file_name} && git -C #{dir} add #{dir} && git -C #{dir} commit -m 'Initialise the repo')
    %x{#{cmd}}
    dir
  end
end
