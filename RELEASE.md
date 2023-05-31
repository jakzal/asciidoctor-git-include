# Release process

1. Sign in to rubygems.org.

    ```bash
    gem signin
    ```

2. Update the release version in `asciidoctor-git-include.gemspec` and tag it.

3. Build the gem.

    ```bash
    gem build asciidoctor-git-include.gemspec 
    ```

4. Push the gem to rubygems.org.

    ```bash
   gem push asciidoctor-git-include-1.1.0.gem
    ```
