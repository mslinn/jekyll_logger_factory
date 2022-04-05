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
  instance = PluginMetaLogger.instance
  logger = instance.new_logger(self) # Should generate a warning
  PluginMetaLogger.instance.info { "How now, brown cow" }
  PluginMetaLogger.instance.debug { "How now, brown cow" }
  PluginMetaLogger.instance.warn { "How now, brown cow" }
  PluginMetaLogger.instance.error { "How now, brown cow" }

  logger = PluginMetaLogger.instance.new_logger(self, RSpec.configuration.site_config)
  logger.debug { "3 fleas fleeing freedom" }
  logger.info { "3 fleas fleeing freedom" }
  logger.warn { "3 fleas fleeing freedom" }
  logger.error { "3 fleas fleeing freedom" }

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
    it "outputs at info level" do
      MyTestPlugin.exercise(PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config, $stdout))
      expect(PluginMetaLogger.instance.level_as_sym).to eq(:info)
    end

    it "uses config debug" do
      logger = PluginMetaLogger.instance.new_logger(:MyBlock, PluginMetaLogger.instance.config)
      expect(logger.level_as_sym).to eq(:debug)
      MyTestPlugin.exercise(logger)
    end

    it "uses config info" do
      logger = PluginMetaLogger.instance.new_logger(:ArchiveDisplayTag, PluginMetaLogger.instance.config)
      expect(logger.level_as_sym).to eq(:info)
      MyTestPlugin.exercise(logger)
    end

    it "uses config warn" do
      logger = PluginMetaLogger.instance.new_logger("SiteInspector", PluginMetaLogger.instance.config, $stdout)
      expect(logger.level_as_sym).to eq(:warn)
      MyTestPlugin.exercise(logger)
    end

    it "uses config error" do
      logger = PluginMetaLogger.instance.new_logger(:PreTagBlock, PluginMetaLogger.instance.config)
      expect(logger.level_as_sym).to eq(:error)
      MyTestPlugin.exercise(logger)
    end
  end
end
