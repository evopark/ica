%w[
  .ruby-version
  .ruby-gemmset
  .rbenv-vars
  tmp/restart.txt
  tmp/caching-dev.txt
].each { |path| Spring.watch(path) }
