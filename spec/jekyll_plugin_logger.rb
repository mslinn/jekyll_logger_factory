# frozen_string_literal: true

require "jekyll"
require_relative "../lib/jekyll_plugin_logger"

class MyTestPlugin
  RSpec.describe(Jekyll) do
    it "shows colored output" do
      Jekyll.logger.info("Info message 1")
      Jekyll.logger.info('MyPlugin', "Info message 2")
      Jekyll.logger.info('MyPlugin') { "Info message 3" }
      Jekyll::Log.info { "Info message 4" }

      Jekyll.logger.warn('MyPlugin') { "Warn message 1" }
      Jekyll::Log.warn { "Warn message 2" }

      Jekyll.logger.error('MyPlugin') { "Error message 1" }
      Jekyll::Log.error { "Error message 2" }
    end
  end
end
