`jekyll_logger_factory`
[![Gem Version](https://badge.fury.io/rb/jekyll_logger_factory.svg)](https://badge.fury.io/rb/jekyll_logger_factory)
===========

`jekyll_logger_factory` is a Ruby gem that provides colored console logs for Jekyll plugins.


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jekyll_logger_factory'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install jekyll_logger_factory


## Usage

It looks within `_config.yml` for a key corresponding to the plugin progname.
For example, if the plugin's progname has value `"abc"` then an entry called `logger_factory.abc`
will be read from the config file, if present.
If the entry exists, its value overrides the value specified when created.
If no such entry is found then the `log_level` value passed to `new` is used.

For example, create a new logger using this Ruby code:
```ruby
LoggerFactory.new('progname', site.config, Logger::WARN)
LoggerFactory.new('progname', site.config)
LoggerFactory.new('progname') # _config.yml settings are ignored
```

Each plugin can have its own logger namespace, or logger namespaces can be shared between plugins,
according to the value of `progname`.

This logger is a subclass of [Jekyll's Stephenson Logger](https://github.com/jekyll/jekyll/blob/master/lib/jekyll/stevenson.rb), which itself is a sublass of the Ruby standard library logger.

For more information about the logging feature in the Ruby standard library,
see https://ruby-doc.org/stdlib-2.7.2/libdoc/logger/rdoc/Logger.html


## Additional Information
More information is available on Mike Slinn's web site about
[Jekyll plugins](https://www.mslinn.com/blog/index.html#Jekyll).


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Install development dependencies like this:
```
$ BUNDLE_WITH="development" bundle install
```

To build and install this gem onto your local machine, run:
```shell
$ bundle exec rake install
jekyll_logger_factory 1.0.0 built to pkg/jekyll_logger_factory-0.1.0.gem.
jekyll_logger_factory (1.0.0) installed.

$ gem info jekyll_logger_factory

*** LOCAL GEMS ***

jekyll_logger_factory (1.0.0)
    Author: Mike Slinn
    Homepage:
    https://github.com/mslinn/jekyll_logger_factory
    License: MIT
    Installed at: /home/mslinn/.gems

    Generates Jekyll logger with colored output.
```

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

Bug reports and pull requests are welcome on GitHub at https://github.com/mslinn/jekyll_logger_factory.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
