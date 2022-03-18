# frozen_string_literal: true

require "jekyll"
require_relative "../lib/jekyll_plugin_logger"

# Output should be:

# Info message 1 (cyan)
#      MyPlugin Info message 2 (cyan)
#     MyPlugin: Info message 3 (cyan)
# MyTestPlugin: Info message 4 (cyan)
# .
#     MyPlugin: Warn message 1 (yellow)
# MyTestPlugin: Warn message 2 (yellow)
#     MyPlugin: Error message 1 (red)
# MyTestPlugin: Error message 2 (red)

class MyTestPlugin
  RSpec.describe(Jekyll) do
    it "shows colored output" do
      Jekyll.logger.info("Info message 1")
      Jekyll.logger.info("MyPlugin", "Info message 2")
      Jekyll.logger.info("MyPlugin") { "Info message 3" }
      Jekyll.info { "Info message 4" }

      Jekyll.logger.warn("MyPlugin") { "Warn message 1" }
      Jekyll.warn { "Warn message 2" }

      Jekyll.logger.error("MyPlugin") { "Error message 1" }
      Jekyll.error { "Error message 2" }
    end
  end
end
