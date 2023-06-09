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
      dir = given_file_committed_to_fresh_repo("chapter01.adoc", "Other repo.")

      input = <<-EOS
include::git@chapter01.adoc[repository=#{dir}]
      EOS

      output = render_embedded_string input

      assert_match(/Other repo\./, output)
    end

    test 'it includes selected lines from a file in the git repository' do
      input = <<-EOS
include::git@test/fixtures/multiline.adoc[lines=2..3;5]
      EOS

      output = render_embedded_string input

      refute_match(/Line 1\./, output)
      assert_match(/Line 2\./, output)
      assert_match(/Line 3\./, output)
      refute_match(/Line 4\./, output)
      assert_match(/Line 5\./, output)
      refute_match(/Line 6\./, output)
    end
  end

  def given_file_committed_to_fresh_repo(file_name)
    dir = Dir.mktmpdir("asciidoctor-git-include-tests-", "/tmp")
    at_exit {
      FileUtils.remove_entry(dir)
    }
    cmd = %(git init -q #{dir} && git -C #{dir} config --local user.email test@example.com && git -C #{dir} config --local user.name Test && echo '#{content}' > #{dir}/#{file_name} && git -C #{dir} add #{dir} && git -C #{dir} commit -m 'Initialise the repo')
    %x{#{cmd}}
    dir
  end
end
