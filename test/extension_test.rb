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

    test 'it includes a diff for a file from the current git repository' do
      input = <<-EOS
include::git@test/fixtures/ruby.rb[revision=35811f53632b96c9473efa6af33e20b442147c51,diff]
      EOS

      output = render_embedded_string input

      # Currently it's not easy to assert on the following expected output.
      # Shall the plugin be developed further, the testing helper would need to be improved
      # on to allow for more readability in tests.
      expected_output = <<-OUTPUT
diff --git a/test/fixtures/ruby.rb b/test/fixtures/ruby.rb
index 9dafbe2..ae70305 100644
--- a/test/fixtures/ruby.rb
+++ b/test/fixtures/ruby.rb
@@ -1,4 +1,4 @@
-messages = ["Hello"]
+messages = ["Hello", "World"]
 messages.each do |m|
   puts m
 end
\ No newline at end of file
      OUTPUT

      assert_match(/diff --git a\/test\/fixtures\/ruby.rb b\/test\/fixtures\/ruby.rb/, output)
      assert_match(/-messages = \["Hello"\]/, output)
      assert_match(/\+messages = \["Hello", "World"\]/, output)
    end

    test 'it includes a diff for a file from the specified repository path' do
      dir = given_file_committed_to_fresh_repo("chapter01.adoc", "Other repo.")
      given_file_updated_in_repo(dir, "chapter01.adoc", "Other repo updated.")

      input = <<-EOS
include::git@chapter01.adoc[repository=#{dir},diff]
      EOS

      output = render_embedded_string input

      assert_match(/-Other repo\./, output)
      assert_match(/\+Other repo updated\./, output)
    end

    test 'it includes a diff for specific revisions of a file' do
      input = <<-EOS
include::git@test/fixtures/ruby.rb[revision=890064c2ee5310fdc4ffec0cffa0e41a258e5b27,diff=0245ac72b958e268b6b28c6c85b524a69021b61c]
      EOS

      output = render_embedded_string input

      assert_match(/diff --git a\/test\/fixtures\/ruby.rb b\/test\/fixtures\/ruby.rb/, output)
      assert_match(/-messages = \["Hello"\]/, output)
      assert_match(/\+messages = \["Hello", "World", "!!!"\]/, output)
    end
  end

  def given_file_committed_to_fresh_repo(file_name, content)
    dir = Dir.mktmpdir("asciidoctor-git-include-tests-", "/tmp")
    at_exit {
      FileUtils.remove_entry(dir)
    }
    cmd = %(git init -q #{dir} && git -C #{dir} config --local user.email test@example.com && git -C #{dir} config --local user.name Test && echo '#{content}' > #{dir}/#{file_name} && git -C #{dir} add #{dir} && git -C #{dir} commit -m 'Initialise the repo')
    %x{#{cmd}}
    dir
  end

  def given_file_updated_in_repo(dir, file_name, content)
    cmd = %(git -C #{dir} config --local user.email test@example.com && git -C #{dir} config --local user.name Test && echo '#{content}' > #{dir}/#{file_name} && git -C #{dir} add #{dir} && git -C #{dir} commit -m 'Initialise the repo')
    %x{#{cmd}}
    dir
  end
end
