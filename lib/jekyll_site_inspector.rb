# frozen_string_literal: true

require_relative "jekyll_site_inspector/version"
require "jekyll"
require "jekyll_logger_factory"

# Dumps lots of information from `site` if in `development` mode and `site_inspector: true` in `_config.yml`.
module Jekyll
  class Error < StandardError; end

  def initialize(config)
    super(config)
    @log = LoggerFactory.new("site_inspector")
  end

  # Displays information about the Jekyll site
  #
  # @param site [Jekyll.Site] Automatically provided by Jekyll plugin mechanism
  # @return [void]
  def generate(site) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/AbcSize
    mode = site.config["env"]["JEKYLL_ENV"]

    config = site.config["site_inspector"]
    return if config.nil?

    inspector_enabled = config != false
    return unless inspector_enabled

    force = config == "force"
    return unless force || mode == "development"

    @log.info "site is of type #{site.class}"
    @log.info "site.time = #{site.time}"
    @log.info "site.config['env']['JEKYLL_ENV'] = #{mode}"
    site.collections.each do |key, _|
      @log.info "site.collections.#{key}"
    end

    # key env contains all environment variables, quite verbose so output is suppressed
    site.config.sort.each { |key, value| @log.info "site.config.#{key} = '#{value}'" unless key == 'env' }

    site.data.sort.each { |key, value| @log.info "site.data.#{key} = '#{value}'" }
    # site.documents.each {|key, value| @log.info "site.documents.#{key}" } # Generates too much output!
    @log.info "site.keep_files: #{site.keep_files.sort}"
    # site.pages.each {|key, value| @log.info "site.pages.#{key}'" } # Generates too much output!
    # site.posts.each {|key, value| @log.info "site.posts.#{key}" }  # Generates too much output!
    site.tags.sort.each { |key, value| @log.info "site.tags.#{key} = '#{value}'" }
  end
end
