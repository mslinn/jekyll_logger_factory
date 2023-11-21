# `jekyll_plugin_logger` [![Gem Version](https://badge.fury.io/rb/jekyll_plugin_logger.svg)](https://badge.fury.io/rb/jekyll_plugin_logger)

`jekyll_plugin_logger` is a Jekyll plugin, packaged as a Ruby gem, that provides colored console logs for Jekyll plugins.


## Usage

`jekyll_plugin_logger` looks within `_config.yml` for a key corresponding to the
fully qualified name of the plugin class.
If the entry exists, its value overrides the value specified when created.
If no such entry is found, then the `log_level` value passed to `new` is used.

Below is a high-level example of how to create and use this plugin.
`site.config` is retrieved from `PluginMetaLogger.instance.config`;
for some plugins, that information is provided as a `site` parameter.
In that circumstance, `site.config` is a less verbose method of obtaining the same information.

```ruby
require "jekyll_plugin_logger"

module MyPlugin1
  @logger = PluginMetaLogger.instance.new_logger(self, PluginMetaLogger.instance.config)

  def my_plugin_method(text, query)
    @logger.debug { "text='#{text}' query='#{query}'" }
    # TODO write the rest of the method
  end

  # TODO write the rest of the plugin
end

PluginMetaLogger.instance.info { "Loaded my_plugin_1 v0.1.0 plugin." }
# Register MyPlugin1 here
```

By default, the above causes output to appear on the console like this:

```text
INFO PluginMetaLogger: Loaded my_plugin_1 v0.1.0 plugin.
DEBUG MyPlugin1:  text='Hello world' query='Bogus query'
```

For more information about the logging feature in the Ruby standard library,
see https://ruby-doc.org/stdlib-2.7.2/libdoc/logger/rdoc/Logger.html


## Installation

Add this line to your Jekyll website's `_config.yml`:

```ruby
group :jekyll_plugins do
  gem 'jekyll_plugin_logger'
end
```

Install all of the dependent gems of your Jekyll website by typing:

```shell
$ bundle
```


## Configuration

The default log level is `info`.
You can change the log level by editing `_config.yml` and adding a `plugin_loggers` section.
Within that section, add an entry for the fully qualified name of your plugin class.
For example, the [`demo`](demo/) contains a Jekyll plugin in [`demo/_plugins/`](demo/_plugins/)
called [`demo_inline_tag.rb`](demo/_plugins/demo_inline_tag.rb).

This plugin&rsquo;s fully qualified class name is `Jekyll::InlineTag`.
The log level can be set to `debug` with the following entry in `_config.yml`:

```yaml
plugin_loggers:
  Jekyll::InlineTag: debug
```

## Additional Information

More information is available on Mike Slinn's web site about
[Jekyll plugins](https://www.mslinn.com/jekyll/10100-custom-logging-in-jekyll-plugins.html).


## Development

After checking out the repo, run `bin/setup` to install dependencies, including development dependencies.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

### Build and Install Locally

To build and install this gem onto your local machine, run:

```shell
$ bundle exec rake install
```

The following also does the same thing:

```shell
$ bundle exec rake install
jekyll_plugin_logger 1.0.0 built to pkg/jekyll_plugin_logger-0.1.0.gem.
jekyll_plugin_logger (1.0.0) installed.
```

Examine the newly built gem:

```shell
$ gem info jekyll_plugin_logger

*** LOCAL GEMS ***

jekyll_plugin_logger (1.0.0)
    Author: Mike Slinn
    Homepage:
    https://github.com/mslinn/jekyll_plugin_logger
    License: MIT
    Installed at: /home/mslinn/.gems

    Generates Jekyll logger with colored output.
```


### Build and Push to RubyGems

To release a new version,

1. Update the version number in `version.rb`.
2. Commit all changes to git; if you don't the next step might fail with an unexplainable error message.
3. Run the following:

   ```shell
   $ bundle exec rake release
   ```

   The above creates a git tag for the version, commits the created tag,
   and pushes the new `.gem` file to [RubyGems.org](https://rubygems.org).


## Contributing

1. Fork the project
2. Create a descriptively named feature branch
3. Add your feature
4. Submit a pull request


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
