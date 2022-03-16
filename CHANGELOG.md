## 1.0.0 / 2022-03-16
  * Published as a gem
  * New instances are now created with `new` instead of `create_logger`
  * Now subclasses Jekyll's Stevenson logger
  * Documentation improved, clarifies that the only supported levels are those provided by the Stevenson logger: `:debug`, `:info`, and `:error`
  * No longer supports control over where log output goes; STDERR and STDOUT are automatically selected according to log level

## 2020-12-28
  * Initial version published at https://www.mslinn.com/blog/2020/12/28/custom-logging-in-jekyll-plugins.html
