# frozen_string_literal: true

require "colorator"
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
  yaml = <<~END_YAML
    plugin_loggers:
      PluginLogger: debug
      SiteInspector: warn
      MakeArchive: error
      ArchiveDisplayTag: debug
  END_YAML

  def self.exercise(logger)
    puts
    # puts "\ncalling_class_name=#{logger.send(:calling_class_name)}"
    logger.debug("Debug message 1")
    # logger.debug("MyPlugin", "Debug message 2")
    # logger.debug("MyPlugin") { "Debug message 3" }
    logger.debug { "Debug message 4" }

    logger.info("Info message 1")
    # logger.info("MyPlugin", "Info message 2")
    # logger.info("MyPlugin") { "Info message 3" }
    logger.info { "Info message 4" }

    logger.warn("Warn message 1")
    # logger.warn("MyPlugin", "Warn message 2")
    # logger.warn("MyPlugin") { "Warn message 3" }
    logger.warn { "Warn message 4" }

    logger.error("Error message 1")
    # logger.error("MyPlugin", "Error message 2")
    # logger.error("MyPlugin") { "Error message 3" }
    logger.error { "Error message 4" }
  end

  RSpec.describe JekyllPluginLogger do
    it "outputs at debug level" do
      MyTestPlugin.exercise(PluginLogger.new(:debug, $stdout, yaml))
    end

    it "uses config warn" do
      logger = PluginLogger.new(:info, $stdout, yaml, "SiteInspector")
      MyTestPlugin.exercise(logger)
    end

    it "uses config error" do
      logger = PluginLogger.new(:info, $stdout, yaml, "MakeArchive")
      MyTestPlugin.exercise(logger)
    end
  end
end
