require 'jekyll_plugin_support'

module Jekyll
  class InlineTag < JekyllSupport::JekyllTag
    VERSION = '0.1.0'.freeze

    def render_impl
      @logger.debug { 'Debug level message' }
      @logger.info  { 'Info level message' }
      @logger.warn  { 'Warn level message' }
      @logger.error { 'Error level message' }

      @logger.DEBUG { 'Debug level message' }
      @logger.INFO  { 'Info level message' }
      @logger.WARN  { 'Warn level message' }
      @logger.ERROR { 'Error level message' }

      '<p>That is all, folks!</p>'
    end

    JekyllPluginHelper.register(self, 'demo_inline_tag')
  end
end
