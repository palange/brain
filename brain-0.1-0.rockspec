package = "brain"
version = "0.1-0"
source = {
  url = "https://github.com/palange/brain/archive/v1.0.tar.gz",
  dir = "brain-0.1"
}
description = {
  summary = "Coroutine Corona Event Handler",
  homepage = "http://github.com/palange/brain",
  license = "MIT <http://opensource.org/licenses/MIT>"
}
dependencies = {
  "lua >= 5.1",
  "busted >= 1.7-1"
}
build = {
  type = "builtin",
  modules = {
    brain = "src/brain.lua"
  }
}
