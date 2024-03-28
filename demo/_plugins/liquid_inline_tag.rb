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
        @msg_debug = "<div class='level_debug'>#{NAME}: Debug level message.</div>"
        remove_html_tags @msg_debug
      end
      @logger.info do
        @msg_info = "<div class='level_info'>#{NAME}: Info level message.</div>"
        remove_html_tags @msg_info
      end
      @logger.warn do
        @msg_warn = "<div class='level_warn'>#{NAME}: Warn level message.</div>"
        remove_html_tags @msg_warn
      end
      @logger.error do
        @msg_error = "<div class='level_error'>#{NAME}: Error level message.</div>"
        remove_html_tags @msg_error
      end
      @logger.fatal do
        @msg_fatal = "<div class='level_fatal'>#{NAME}: Fatal level message.</div>"
        remove_html_tags @msg_fatal
      end
      @logger.unknown do
        @msg_unknown = "<div class='level_unknown'>#{NAME}: Unknown level message.</div>"
        remove_html_tags @msg_unknown
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
