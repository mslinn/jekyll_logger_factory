# frozen_string_literal: true

require_relative "jekyll_plugin_logger/version"
require "jekyll"
require "yaml"

# Looks within _config.yml for a key corresponding to the plugin progname.
# For example, if the plugin's progname has value "abc" then an entry called logger_factory.abc
# will be read from the config file, if present.
# If the entry exists, its value overrides the value specified when create_logger() was called.
# If no such entry is found then the log_level value specified when create_logger() was called is used.
# In the absence of any configuration, log_level defaults to :info.
#
# @example  If your plugin is defined in a class called `MyPluginClass` then the YAML to override the
# programmatically set `log_level` to `debug` is:
#   plugin_loggers:
#     MyPluginClass: debug
#
# For more information about the logging feature in the Ruby standard library,
# @see https://ruby-doc.org/stdlib-2.7.2/libdoc/logger/rdoc/Logger.html

module Jekyll
  # Monkeypatch the Jekyll logger so :info messages are colored cyan
  class Stevenson < ::Logger
    # Log an +INFO+ message, with color
    def info(progname = nil, &block)
      add(INFO, nil, progname.cyan, &block)
    end
  end

  # Monkey patch LogAdapter.initialize so loglevel can be set from _config.yml
  class LogAdapter
    # Public: Create a new instance of a log writer
    #
    # writer - Logger compatible instance
    # log_level - (optional, symbol) the log level
    #
    # Returns nothing
    def initialize(writer, level = :info)
      @messages = []
      @writer = writer
      self.log_level = yaml_log_level || level
    end

    private

    # @param config [YAML] Configuration data that might contain a entry for `logger_factory`
    # @param progname [String] The name of the `config` subentry to look for underneath the `logger_factory` entry
    # @return [String, FalseClass]
    def yaml_log_level
      yaml_str = File.read("_config.yml")
      return false if yaml_str.nil? || yaml_str.strip.empty?

      config = YAML.safe_load(yaml_str)
      log_config = config["plugin_loggers"]
      return false if log_config.nil?

      progname_log_level = log_config[Log.calling_class_name]
      return false if progname_log_level.nil?

      ENV["JEKYLL_LOG_LEVEL"] = progname_log_level
    end
  end

  # Convenience methods
  def self.calling_class_name
    caller(2..2).first.split(%r!/|[[:punct:]]+!).last
  end

  def self.info(progname = nil, &block)
    progname = calling_class_name if progname.nil?
    Jekyll.logger.info(progname) { yield block }
  end

  def self.warn(progname = nil, &block)
    progname = calling_class_name if progname.nil?
    Jekyll.logger.warn(progname) { yield block }
  end

  def self.error(progname = nil, &block)
    progname = calling_class_name if progname.nil?
    Jekyll.logger.error(progname) { yield block }
  end
end
