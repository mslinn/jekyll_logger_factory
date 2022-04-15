# frozen_string_literal: true

require "colorator"
require "logger"
require "singleton"
require "yaml"
require_relative "jekyll_plugin_logger/version"

module JekyllPluginLoggerName
  PLUGIN_NAME = "jekyll_plugin_logger"
end

# Once the meta-logger is made (see `PluginMetaLogger`, below) new instances of `PluginLogger` can be created with log levels set
# by `config` entries.
# @example Create new `PluginLogger`s like this:
#   @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
#
# self can be a module, a class, a string, or a symbol.
#
# Best practice is to invoke `info`, `warn, `debug` and `error` methods by passing blocks that contain the message.
# The blocks will only be evaluated if output for that level is enabled.
# @example Use `PluginLogger`s like this:
#   @logger.info { "This is only evaluated if info level debugging is enabled" }
#
# For more information about the logging feature in the Ruby standard library,
# @see https://ruby-doc.org/stdlib-2.7.1/libdoc/logger/rdoc/Logger.html
class PluginLogger
  # This method should only be called by PluginMetaLogger
  # @param log_level [String, Symbol, Integer] can be specified as $stderr or $stdout,
  #   or an integer from 0..3 (inclusive),
  #   or as a case-insensitive string
  #   (`debug`, `info`, `warn`, `error`, or `DEBUG`, `INFO`, `WARN`, `ERROR`),
  #   or as a symbol (`:debug`, `:info`, `:warn`, `:error` ).
  #
  # @param config [YAML] is normally created by reading a YAML file such as Jekyll's `_config.yml`.
  #   When invoking from a Jekyll plugin, provide `site.config`,
  #   which is available from all types of Jekyll plugins as `Jekyll.configuration({})`.
  #
  # @example  If `progname` has value `abc`, then the YAML to override the programmatically set log_level to `debug` is:
  #   logger_factory:
  #     abc: debug
  def initialize(klass, config = nil, stream_name = $stdout)
    @config = config
    @logger = Logger.new(stream_name)
    @logger.progname = derive_progname(klass)
    @logger.level = :info
    plugin_loggers = config ? config["plugin_loggers"] : nil
    @logger.level = plugin_loggers[@logger.progname] if plugin_loggers && plugin_loggers[@logger.progname]
    # puts "PluginLogger.initialize: @logger.progname=#{@logger.progname} set to #{@logger.level}".red
    @logger.formatter = proc { |severity, _, prog_name, msg|
      "#{severity} #{prog_name}: #{msg}\n"
    }
  end

  def debug(progname = nil, &block)
    if block
      @logger.debug(@logger.progname) { (yield block).to_s.magenta }
    else
      @logger.debug(@logger.progname) { progname.to_s.magenta }
    end
  end

  def info(progname = nil, &block)
    if block
      @logger.info(@logger.progname) { (yield block).to_s.cyan }
    else
      @logger.info(@logger.progname) { progname.to_s.cyan }
    end
  end

  def level=(value)
    @logger.level = value
  end

  def level
    @logger.level
  end

  def progname=(value)
    @logger.progname = value
  end

  def progname
    @logger.progname
  end

  def warn(progname = nil, &block)
    if block
      @logger.warn(@logger.progname) { (yield block).to_s.yellow }
    else
      @logger.warn(@logger.progname) { progname.to_s.yellow }
    end
  end

  def error(progname = nil, &block)
    if block
      @logger.error(@logger.progname) { (yield block).to_s.red }
    else
      @logger.error(@logger.progname) { progname.to_s.red }
    end
  end

  # Available colors are: :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white, and the modifier :bold
  def level_as_sym
    return :unknown if @logger.level.negative? || level > 4

    [:debug, :info, :warn, :error, :fatal, :unknown][@logger.level]
  end

  private

  def derive_progname(klass)
    class_name = klass.class.to_s
    case class_name
    when "Class"
      klass.to_s.split("::").last # class_name.name.split("::").last
    when "Module", "Symbol", "String"
      klass.to_s.split("::").last
    else
      class_name
    end
  end
end

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

  def info
    @logger.info(self) { yield }
  end

  def debug
    @logger.debug(self) { yield }
  end

  def level_as_sym
    @logger.level_as_sym
  end

  def warn
    @logger.warn(self) { yield }
  end

  def error
    @logger.error(self) { yield }
  end

  def new_logger(klass, config = nil, stream_name = $stdout)
    @config ||= config
    if @config.nil?
      puts { "Error: PluginMetaLogger has not been initialized with site.config.".red }
      PluginLogger.new(klass, {}, stream_name)
    else
      PluginLogger.new(klass, @config, stream_name)
    end
  end
end

Jekyll::Hooks.register(:site, :after_reset, :priority => :high) do |site|
  instance = PluginMetaLogger.instance
  logger = instance.new_logger(PluginMetaLogger, site.config)
  logger.info { "Loaded #{JekyllPluginLoggerName::PLUGIN_NAME} v#{JekyllPluginLoggerVersion::VERSION} plugin." }
  logger.debug { "Logger for #{instance.logger.progname} created at level #{instance.level_as_sym}" }
end
