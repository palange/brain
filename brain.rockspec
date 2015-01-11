package = "brain"
version = "0.1"
source = {
  url = "https://github.com/palange/corona-brain",
}
description = {
  summary = "Coroutine Corona Event Handler",
  homepage = "http://github.com/palange/corona-brain"
  license = "MIT <http://opensource.org/licenses/MIT>"
}
dependencies = {
  "lua >= 5.1",
  "busted >= 1.7-1"
}
build = {
  type = "builtin",
  modules = {
    ["brain"] = "src/brain.lua",
  }
}
