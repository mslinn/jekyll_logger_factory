require 'jekyll_plugin_support'

# This example uses `jekyll_plugin_support` framework to define an inline tag plugin.
# The framework provides a `jekyll_plugin_logger` instance called `@logger` for each plugin that it defines.
module Support
  class InlineTag < JekyllSupport::JekyllTag
    NAME = 'support_tag'.freeze
    VERSION = '0.1.0'.freeze

    def render_impl
      @logger.debug do
        @msg_debug = "<div class='level_debug'>#{@tag_name}: Debug level message.</div>"
        remove_html_tags @msg_debug
      end
      @logger.info do
        @msg_info = "<div class='level_info'>#{@tag_name}: Info level message.</div>"
        remove_html_tags @msg_info
      end
      @logger.warn do
        @msg_warn = "<div class='level_warn'>#{@tag_name}: Warn level message.</div>"
        remove_html_tags @msg_warn
      end
      @logger.error do
        @msg_error = "<div class='level_error'>#{@tag_name}: Error level message.</div>"
        remove_html_tags @msg_error
      end
      @logger.fatal do
        @msg_fatal = "<div class='level_fatal'>#{@tag_name}: Fatal level message.</div>"
        remove_html_tags @msg_error
      end
      @logger.unknown do
        @msg_unknown = "<div class='level_unknown'>#{@tag_name}: Unknown level message.</div>"
        remove_html_tags @msg_error
      end

      "#{@msg_debug}#{@msg_info}#{@msg_warn}#{@msg_error}#{@msg_fatal}#{@msg_unknown}"
    end

    private

    def remove_html_tags(string)
      string.gsub(/<[^>]*>/, '')
    end

    JekyllPluginHelper.register(self, NAME)
    PluginMetaLogger.instance.info { "Loaded #{NAME} #{VERSION} plugin." }
  end
end
