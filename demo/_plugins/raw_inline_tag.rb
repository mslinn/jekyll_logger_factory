require 'jekyll'
require 'jekyll_plugin_logger'

module Raw
  NAME = 'raw_inline_tag'.freeze
  VERSION = '0.1.0'.freeze

  class InlineTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)
      @text = text
    end

    def render(_context)
      @logger.debug do
        @msg_debug = "<div style='color: magenta;'>#{NAME}: Debug level message.</div>"
        remove_html_tags @msg_debug
      end
      @logger.info do
        @msg_info = "<div style='color: blue;'>#{NAME}: Info level message.</div>"
        remove_html_tags @msg_info
      end
      @logger.warn do
        @msg_warn = "<div style='color: #ffcc00;'>#{NAME}: Warn level message.</div>"
        remove_html_tags @msg_warn
      end
      @logger.error do
        @msg_error = "<div style='color: red;'>#{NAME}: Error level message.</div>"
        remove_html_tags @msg_error
      end

      "#{@msg_debug}#{@msg_info}#{@msg_warn}#{@msg_error}"
    end

    def remove_html_tags(string)
      string.gsub(/<[^>]*>/, '')
    end
  end

  Liquid::Template.register_tag(NAME, Raw::InlineTag)
  PluginMetaLogger.instance.info { "Loaded #{NAME} #{VERSION} plugin." }
end
