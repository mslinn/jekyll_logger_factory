require 'jekyll'
require 'jekyll_plugin_logger'

module Raw
  NAME = 'liquid_tag'.freeze
  VERSION = '0.1.0'.freeze

  class InlineTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      @text = text
    end

    def render(_context)
      @logger.debug do
        @msg_debug = "<div class='debug'>#{NAME}: Debug level message (#{@logger.level}).</div>"
        remove_html_tags @msg_debug
      end
      @logger.info do
        @msg_info = "<div class='info'>#{NAME}: Info level message (#{@logger.level}).</div>"
        remove_html_tags @msg_info
      end
      @logger.warn do
        @msg_warn = "<div class='warn'>#{NAME}: Warn level message (#{@logger.level}).</div>"
        remove_html_tags @msg_warn
      end
      @logger.error do
        @msg_error = "<div class='error'>#{NAME}: Error level message (#{@logger.level}).</div>"
        remove_html_tags @msg_error
      end
      @logger.fatal do
        @msg_fatal = "<div class='fatal'>#{NAME}: Fatal level message (#{@logger.level}).</div>"
        remove_html_tags @msg_error
      end
      @logger.unknown do
        @msg_unknown = "<div class='unknown'>#{NAME}: Unknown level message (#{@logger.level}).</div>"
        remove_html_tags @msg_error
      end

      "#{@msg_debug}#{@msg_info}#{@msg_warn}#{@msg_error}#{@msg_fatal}#{@msg_unknown}"
    end

    def remove_html_tags(string)
      string.gsub(/<[^>]*>/, '')
    end
  end

  Liquid::Template.register_tag(NAME, Raw::InlineTag)
  PluginMetaLogger.instance.info { "Loaded #{NAME} #{VERSION} plugin." }
end
