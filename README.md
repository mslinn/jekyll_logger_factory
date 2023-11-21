# `jekyll_plugin_logger` [![Gem Version](https://badge.fury.io/rb/jekyll_plugin_logger.svg)](https://badge.fury.io/rb/jekyll_plugin_logger)

`jekyll_plugin_logger` is a Jekyll plugin, packaged as a Ruby gem, that provides colored console logs for Jekyll plugins.
It is based on the standard Ruby [`Logger`](https://ruby-doc.org/stdlib-3.1.0/libdoc/logger/rdoc/Logger.html) class.

Log levels are normally set from `_config.yml`:

* 0: `debug`
* 1: `info`
* 2: `warn`
* 3: `error`
* 4: `fatal`
* 5: `unknown` (displays as `ANY`)


## Usage

The [`demo/_plugins/`](demo/_plugins/) directory demonstrates two ways of working with `jekyll_plugin_logger`:

* `liquid_tag.rb`, a Jekyll plugin subclassed from
  [`Liquid::Tag`](https://jekyllrb.com/docs/plugins/tags/).
* `support_tag.rb`, a Jekyll plugin subclassed from
  [`JekyllSupport::JekyllTag`](https://www.mslinn.com/jekyll_plugins/jekyll_plugin_support.html).


## Installation

Add the line to your Jekyll website's `_config.yml`:

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

For example, the fully qualified class names of the Jekyll plugins provided in `demo/_plugins/`
are `Raw::InlineTag` and `Support::InlineTag`, respectively.
Their log levels can be set to `debug` with the following entries in [`_config.yml`](demo/_config.yml):

```yaml
plugin_loggers:
  Raw::InlineTag: debug     # Notice the module name is specified as well as the class name
  Support::InlineTag: debug # Notice the module name is specified as well as the class name
```


## Run the Demo

Run the demo by typing:

```shell
$ demo/_bin/debug -r
```

See what happens to the output when you edit the logging levels in the `plugin_loggers` section of `_config.yml`.
You will have to restart the demo after each modification to `_config.yml`
in order to see the output change.


## Additional Information

More information is available on Mike Slinn's web site about
[Jekyll plugins](https://www.mslinn.com/jekyll/10100-custom-logging-in-jekyll-plugins.html).


## Development

After checking out the `jekyll_plugin_logger` repository,
run `bin/setup` to install dependencies,
which includes development dependencies.

You can then run `bin/console` for an interactive prompt that will allow you to experiment.


### Build and Install Locally

To build and install this gem onto your local machine, run:

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

    Generates a Jekyll logger with colored output.
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
