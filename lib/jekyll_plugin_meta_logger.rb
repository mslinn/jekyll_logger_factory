require 'colorator'
require 'logger'
require 'singleton'

# Makes a meta-logger instance (a singleton) with level set by `site.config`.
# Saves `site.config` for later use when creating plugin loggers; these loggers each have their own log levels.
#
# For example, if the plugin's progname has value `MyPlugin` then an entry called `plugin_loggers.MyPlugin`
# will be read from `config`, if present.
# If no such entry is found then the meta-logger log_level is set to `:info`.
# If you want to see messages that indicate the loggers and log levels as they are created,
# set the log level for `PluginMetaLogger` to `debug` in `_config.yml`
#
# @example
#   # Create and initialize the meta-logger singleton in a high priority Jekyll `site` `:after_init` hook:
#   @meta_logger = PluginMetaLogger.instance.new_logger(site.config, self)
#   @meta_logger.info { "Meta-logger has been created" }
#
#   # In `config.yml`:
#   plugin_loggers:
#     PluginMetaLogger: info
#     MyPlugin: warn
#     MakeArchive: error
#     ArchiveDisplayTag: debug
#
#   # In a Jekyll plugin:
#   @logger = PluginMetaLogger.instance.setup(self)
#   @logger.info { "This is a log message from a Jekyll plugin" }
#   #
#   PluginMetaLogger.instance.info { "MyPlugin vX.Y.Z has been loaded" }
class PluginMetaLogger
  include Singleton
  attr_reader :config, :logger

  def initialize
    super
    @config = nil
    @logger = new_logger(self)
  end

  def info(&block)
    @logger.info(self) { yield block }
  end

  def debug(&block)
    @logger.debug(self) { yield block }
  end

  def level_as_sym
    @logger.level_as_sym
  end

  def warn(&block)
    @logger.warn(self) { yield block }
  end

  def error(&block)
    @logger.error(self) { yield block }
  end

  # By the time this method is called, `PluginMetaLogger.instance.config` contains the entire contents of `_config.yml`
  def new_logger(klass, config = nil, stream_name = $stdout)
    @config ||= config
    if @config.nil?
      logger = PluginLogger.new(klass, {}, stream_name)
      logger.debug { 'PluginMetaLogger was not initialized from site.config.' }
    else
      logger = PluginLogger.new(klass, @config, stream_name)
      logger.debug { 'PluginMetaLogger was initialized from site.config.' }
    end
    logger
  end
end
