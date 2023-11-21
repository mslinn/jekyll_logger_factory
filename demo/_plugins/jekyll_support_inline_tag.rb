require 'jekyll_plugin_support'

# This example uses `jekyll_plugin_support` framework to define an inline tag plugin.
# The framework provides a `jekyll_plugin_logger` instance called `@logger` for each plugin that it defines.
module Support
  class InlineTag < JekyllSupport::JekyllTag
    VERSION = '0.1.0'.freeze

    def render_impl
      @logger.debug do
        @msg_debug = "<div style='color: magenta;'>#{@tag_name}: Debug level message.</div>"
        remove_html_tags @msg_debug
      end
      @logger.info do
        @msg_info = "<div style='color: blue;'>#{@tag_name}: Info level message.</div>"
        remove_html_tags @msg_info
      end
      @logger.warn do
        @msg_warn = "<div style='color: #ffcc00;'>#{@tag_name}: Warn level message.</div>"
        remove_html_tags @msg_warn
      end
      @logger.error do
        @msg_error = "<div style='color: red;'>#{@tag_name}: Error level message.</div>"
        remove_html_tags @msg_error
      end

      "#{@msg_debug}#{@msg_info}#{@msg_warn}#{@msg_error}"
    end

    private

    def remove_html_tags(string)
      string.gsub(/<[^>]*>/, '')
    end

    JekyllPluginHelper.register(self, 'jekyll_plugin_support_tag')
  end
end
