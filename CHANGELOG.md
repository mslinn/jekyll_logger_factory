## 2.1.1 / 2022-04-15
  * Fixed progname reference for metalogger debug startup statement

## 2.1.0 / 2022-04-05
  * Changed how config info is made available

## 2.0.1 / 2022-04-05
  * Changed to registration hook to `:site`, `:after_reset` because that is the first hook that gets called.
  * Improved the detection of various types of `progname`

## 2.0.0 / 2022-03-16
  * Completely rewrote this plugin, now not a class, but a module that monkey patches the existing Jekyll logger for compatibility.
  * Renamed the gem from `jekyll_logger_factory` to `jekyll_plugin_logger`.
  * Automatically obtains plugin class name and uses that as `progname`.
  * `:into` level output is colored cyan.

## 1.0.0 / 2022-03-16
  * Published as a gem.
  * New instances are now created with `new` instead of `create_logger`.
  * Now subclasses Jekyll's Stevenson logger.
  * Documentation improved, clarifies that the only supported levels are those provided by the Stevenson logger: `:debug`, `:info`, and `:error`.
  * No longer supports control over where log output goes; STDERR and STDOUT are automatically selected according to log level.

## 2020-12-28
  * Initial version published at https://www.mslinn.com/blog/2020/12/28/custom-logging-in-jekyll-plugins.html
