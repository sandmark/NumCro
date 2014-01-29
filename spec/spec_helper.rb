require "simplecov"
SimpleCov.start

require "active_support/core_ext"

def current_dir(file)
  File.dirname(__FILE__) + "/../#{file}"
end
