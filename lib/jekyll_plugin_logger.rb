# frozen_string_literal: true

require "colorator"
require "logger"
require "singleton"
require "yaml"
require_relative "jekyll_plugin_logger/version"

module JekyllPluginLoggerName
  PLUGIN_NAME = "jekyll_plugin_logger"
end

# Once the meta-logger is made (see PluginMetaLogger) new instances of PluginLogger can be created with log levels set by config entries.
# @example Create a new logger using this code like this:
#   PluginMetaLogger.instance.new_logger(self)
#
# self can be a class, a string, or a symbol.
#
# For more information about the logging feature in the Ruby standard library,
# @see https://ruby-doc.org/stdlib-2.7.1/libdoc/logger/rdoc/Logger.html
class PluginLogger
  include JekyllPluginLogger
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
  def initialize(klass, config, stream_name = $stdout)
    @logger = Logger.new(stream_name)
    @logger.progname = (klass.is_a?(Class) ? klass.name : klass.to_s).split("::").last
    @logger.level = :info
    plugin_loggers = config["plugin_loggers"]
    @logger.level ||= plugin_loggers["PluginMetaLogger"] if plugin_loggers
    # puts "PluginLogger.initialize: @logger.progname=#{@logger.progname} set to #{@logger.level}".red
    @logger.formatter = proc { |severity, _, prog_name, msg|
      "#{severity} #{prog_name}: #{msg}\n"
    }
  end

  # Available colors are: :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white, and the modifier :bold
  def level_as_sym
    return :unknown if @logger.level.negative? || level > 4

    [:debug, :info, :warn, :error, :fatal, :unknown][@logger.level]
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
end

# Makes a meta logger instance (a singleton) with level set by site.config
# Saves site.config for later use when creating plugin loggers.
# For example, if the plugin's progname has value "abc" then an entry called logger_factory.abc
# will be read from the config file, if present.
# If the entry exists, its value overrides the value specified when create_logger() was called.
# If no such entry is found then the log_level value specified when create_logger() was called is used.
# @example
#   logger = PluginMetaLogger.instance.setup(site.config)
#   logger.debug { "3 fleas fleeing freedom" }
class PluginMetaLogger
  include Singleton
  attr_reader :logger

  def initialize
    super
    @config = nil
    @logger = new_logger(self, $stdin)
  end

  def info
    @logger.info(self) { yield }
  end

  def debug
    @logger.debug(self) { yield }
  end

  def warn
    @logger.warn(self) { yield }
  end

  def error
    @logger.error(self) { yield }
  end

  def new_logger(klass, stream_name = $stdout)
    if @config.nil?
      puts { "Error: PluginMetaLogger has not been initialized by calling setup yet.".red }
      PluginLogger.new(klass, {}, stream_name)
    else
      PluginLogger.new(klass, @config, stream_name)
    end
  end

  def setup(config, stream_name = $stdout)
    @config = config
    @logger = new_logger(self, stream_name)
    @logger
  end
end

Jekyll::Hooks.register(:site, :after_init, :priority => :high) do |site|
  instance = PluginMetaLogger.instance
  logger = instance.setup(site.config)
  logger.warn { "Loaded #{JekyllPluginLoggerName::PLUGIN_NAME} v#{JekyllPluginLogger::VERSION} plugin." }
  logger.debug { "Logger for #{instance.progname} created at level #{instance.level_as_sym}" }
end
