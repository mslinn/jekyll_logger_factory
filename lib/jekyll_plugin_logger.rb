# frozen_string_literal: true

require "colorator"
require "logger"
require "singleton"
require "yaml"
require_relative "jekyll_plugin_logger/version"

module JekyllPluginLoggerName
  PLUGIN_NAME = "jekyll_plugin_logger"
end

# Looks within _config.yml for a key corresponding to the plugin progname.
# For example, if the plugin's progname has value "abc" then an entry called logger_factory.abc
# will be read from the config file, if present.
# If the entry exists, its value overrides the value specified when create_logger() was called.
# If no such entry is found then the log_level value specified when create_logger() was called is used.
#
# @example Create a new logger using this code like this:
#   LoggerFactory.new.create_logger('my_tag_name', site.config, Logger::WARN, $stderr)
#
# For more information about the logging feature in the Ruby standard library,
# @see https://ruby-doc.org/stdlib-2.7.1/libdoc/logger/rdoc/Logger.html
#
# Available colors are: :black, :red, :green, :yellow, :blue, :magenta, :cyan, :white, and the modifier :bold
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
  def initialize(klass, log_level = :info, stream_name = $stdout, yaml_str = nil)
    @logger = Logger.new(stream_name)
    @logger.progname = klass.class.name.split("::").last
    @logger.level = PluginLogger.yaml_log_level(yaml_str, @logger.progname) || log_level
    puts "PluginLogger.initialize: @logger.progname=#{@logger.progname} set to #{@logger.level}".red
    @logger.formatter = proc { |severity, _, prog_name, msg|
      "#{severity} #{prog_name}: #{msg}\n"
    }
  end

  def self.calling_class_name
    call_stack = caller
    # puts "\n\ncall_stack[0..10]=\n  #{call_stack[0..10].join("\n  ")}"
    calling_class = call_stack.find { |item| item.include? "<class:" }
    return nil unless calling_class

    # puts "calling_class=#{calling_class}"
    calling_class.split(%r!/|[[:punct:]]+!).last
  end

  # @param config [YAML] Configuration data that might contain a entry for `logger_factory`
  # @param progname [String] The name of the `config` subentry to look for underneath the `logger_factory` entry
  # @return [String, FalseClass]
  def self.yaml_log_level(yaml_str, klass_name)
    yaml_str = File.read("_config.yml") if yaml_str.nil? || yaml_str.strip.empty?
    config = YAML.safe_load(yaml_str)
    log_config = config["plugin_loggers"]
    return nil if log_config.nil?

    progname_log_level = log_config[klass_name]
    return nil if progname_log_level.nil? || progname_log_level.strip.empty?

    puts "#{klass_name} log level set to #{progname_log_level} by _config.yml entry.".red

    progname_log_level
  end

  def level_as_sym
    return :unknown if @logger.level.negative? || level > 4

    [:debug, :info, :warn, :error, :fatal, :unknown][@logger.level]
  end

  def debug(progname = nil, &block)
    if block
      progname = PluginLogger.calling_class_name if progname.nil?
      @logger.debug(progname) { (yield block).to_s.magenta }
    else
      @logger.debug(PluginLogger.calling_class_name) { progname.to_s.magenta }
    end
  end

  def info(progname = nil, &block)
    if block
      progname = PluginLogger.calling_class_name if progname.nil?
      @logger.info(progname) { (yield block).to_s.cyan }
    else
      @logger.info(PluginLogger.calling_class_name) { progname.to_s.cyan }
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
      progname = PluginLogger.calling_class_name if progname.nil?
      @logger.warn(progname) { (yield block).to_s.yellow }
    else
      @logger.warn(PluginLogger.calling_class_name) { progname.to_s.yellow }
    end
  end

  def error(progname = nil, &block)
    if block
      progname = PluginLogger.calling_class_name if progname.nil?
      @logger.error(progname) { (yield block).to_s.red }
    else
      @logger.error(PluginLogger.calling_class_name) { progname.to_s.red }
    end
  end
end

class PluginMetaLogger < PluginLogger
  include Singleton

  def initialize(log_level = :info, stream_name = $stdout, yaml_str = nil)
    super(self, log_level, stream_name, yaml_str)
  end
end

unless ENV["jekyll_plugin_logger_created_already"]
  ENV["jekyll_plugin_logger_created_already"] = "true"
  instance = PluginMetaLogger.instance
  instance.level = if caller.find { |item| item.include? "gems/rspec-core" }
                     "debug"
                   else
                     x = PluginLogger.yaml_log_level(yaml_str, PluginMetaLogger.instance.progname)
                     x.nil? || x.empty? ? :info : x
                   end
  instance.info { "Loaded #{JekyllPluginLoggerName::PLUGIN_NAME} v#{JekyllPluginLogger::VERSION} plugin." }
  instance.debug { "Logger for #{instance.progname} created at level #{instance.level_as_sym}" }
end
