# frozen_string_literal: true

require_relative "jekyll_logger_factory/version"
require "jekyll"
require "yaml"

# Looks within _config.yml for a key corresponding to the plugin progname.
# For example, if the plugin's progname has value "abc" then an entry called logger_factory.abc
# will be read from the config file, if present.
# If the entry exists, its value overrides the value specified when create_logger() was called.
# If no such entry is found then the log_level value specified when create_logger() was called is used.
# In the absence of any configuration, log_level defaults to :info.
#
# @example Create a new logger using this code like this:
#   LoggerFactory.new('my_tag_name', Logger::INFO)
#   LoggerFactory.new('my_tag_name')
#
# my_tag_name should be used as the name to register the Jekyll plugin.
#
# @example  If `my_tag_name` has value `abc`, then the YAML to override the programmatically set log_level to `debug` is:
#   logger_factory:
#     abc: debug
#
# For more information about the logging feature in the Ruby standard library,
# @see https://ruby-doc.org/stdlib-2.7.2/libdoc/logger/rdoc/Logger.html

module Jekyll
  class Error < StandardError; end

  class LoggerFactory < Jekyll::Stevenson
    attr_writer :config

    # @progname [String] is the namespace that you want to control logging for.
    #   Each plugin can have its own namespace, or namespaces can be shared between plugins.
    #
    # @param config [YAML] is normally created by reading a YAML file such as Jekyll's `_config.yml`.
    #   When invoking from a Jekyll plugin, provide `site.config`,
    #   which is available from all types of Jekyll plugins as `Jekyll.configuration({})`.
    #
    # @param log_level [String, Symbol, Integer] can be specified as $stderr or $stdout,
    #   or an integer,
    #   or as a case-insensitive string
    #   (`'debug'` (0), `'info'` (1), `'error'` (3), or `'DEBUG'`, `'INFO'`, `'ERROR'`),
    #   or as a symbol (`:debug`, `:info`, `:error` ).
    #   This is an optional parameter, and it is overridden by the value of the logger_factory progname debug level if set in _config.yml
    def initialize(progname, log_level = Logger::INFO)
      super()

      @logger = Stevenson.new
      @logger.progname = progname
      @logger.level = yaml_log_level || log_level
      @logger.formatter = proc { |severity, _, prog_name, msg|
        "#{severity} #{prog_name}: #{msg}\n"
      }
    end

    def level
      @logger.level
    end

    def level=(new_value)
      @logger.level = new_value
    end

    def progname
      @logger.progname
    end

    private

    # @param config [YAML] Configuration data that might contain a entry for `logger_factory`
    # @param progname [String] The name of the `config` subentry to look for underneath the `logger_factory` entry
    # @return [String, FalseClass]
    def yaml_log_level
      yaml_str = File.read("_config.yml")
      return false if yaml_str.nil? || yaml_str.strip.empty?

      config = YAML.safe_load(yaml_str)
      log_config = config["logger_factory"]
      return false if log_config.nil?

      progname_log_level = log_config[@logger.progname]
      return false if progname_log_level.nil?

      progname_log_level
    end
  end
end
