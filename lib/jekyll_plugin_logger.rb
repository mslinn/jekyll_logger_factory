require 'colorator'
require 'logger'
require 'yaml'
require_relative 'jekyll_plugin_logger/version'
require_relative 'jekyll_plugin_meta_logger'

module JekyllPluginLoggerName
  PLUGIN_NAME = 'jekyll_plugin_logger'.freeze
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
  # 0: debug
  # 1: info
  # 2: warn
  # 3: error
  # 4: fatal
  # 5: unknown (displays as ANY)
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
    plugin_loggers = config&.[] 'plugin_loggers'

    @logger = Logger.new stream_name
    @logger.progname = derive_progname klass
    @logger.level = :info
    @logger.level = plugin_loggers[@logger.progname] if plugin_loggers&.[] @logger.progname
    # puts "PluginLogger.initialize: @logger.progname=#{@logger.progname} set to #{@logger.level}".red
    @logger.formatter = proc { |severity, _datetime, progname, msg|
      "#{severity} #{progname}: #{msg}\n"
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

  # @return the log level specified in _config.yml, or :info (1) if not specified
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

  def fatal(progname = nil, &block)
    if block
      @logger.fatal(@logger.progname) { (yield block).to_s.green }
    else
      @logger.fatal(@logger.progname) { progname.to_s.green }
    end
  end

  # @return the log level specified in _config.yml, or :info (1) if not specified
  # Available colors are: :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white, and the modifier :bold
  def level_as_sym
    return :unknown if @logger.level.negative? || level > 4

    %i[debug info warn error fatal unknown][@logger.level]
  end

  def unknown(progname = nil, &block)
    if block
      @logger.unknown(@logger.progname) { (yield block).to_s }
    else
      @logger.unknown(@logger.progname) { progname.to_s }
    end
  end

  private

  def derive_progname(klass)
    class_name = klass.class.to_s
    case class_name
    when 'Class', 'Module', 'Symbol', 'String'
      klass.to_s.split('::').last
    else
      class_name
    end
  end
end

Jekyll::Hooks.register(:site, :after_reset, priority: :high) do |site|
  instance = PluginMetaLogger.instance
  logger = instance.new_logger(PluginMetaLogger, site.config)
  logger.info { "Loaded #{JekyllPluginLoggerName::PLUGIN_NAME} v#{JekyllPluginLoggerVersion::VERSION} plugin." }
  logger.debug { "Logger for #{instance.logger.progname} created at level #{instance.level_as_sym}" }
end
