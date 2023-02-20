require 'jekyll'
require_relative '../lib/jekyll_plugin_logger'

Jekyll.logger.log_level = :info

RSpec.configure do |config|
  plugin_config = <<~END_CONFIG
    plugin_loggers:
      ArchiveDisplayTag: info
      FlexibleInclude: info
      MakeArchive: info
      MyBlock: debug
      PluginMetaLogger: info
      PreTagBlock: error
      SiteInspector: warn
      UnselectableTag: info
  END_CONFIG

  config.add_setting :site_config
  config.site_config = YAML.safe_load(plugin_config)

  config.filter_run :focus
  config.order = 'random'
  config.run_all_when_everything_filtered = true

  # See https://relishapp.com/rspec/rspec-core/docs/command-line/only-failures
  config.example_status_persistence_file_path = 'spec/status_persistence.txt'
end
