# frozen_string_literal: true

require "jekyll"
require_relative "../lib/jekyll_logger_factory"

RSpec.describe(Jekyll) do
  include Jekyll
  require "logger"

  it "is created properly" do
    log = Jekyll::LoggerFactory.new("my_tag_template", Jekyll.configuration({}), :info)
    expect(log.level).to eq(Logger::INFO)

    log = Jekyll::LoggerFactory.new("my_tag_template", Jekyll.configuration({}), :debug)
    expect(log.level).to eq(Logger::DEBUG)

    log = Jekyll::LoggerFactory.new("my_tag_template", Jekyll.configuration({}), :error)
    expect(log.level).to eq(Logger::ERROR)

    log = Jekyll::LoggerFactory.new("my_tag_template", Jekyll.configuration({}))
    expect(log.level).to eq(Logger::INFO)

    log = Jekyll::LoggerFactory.new("my_tag_template")
    expect(log.level).to eq(Logger::INFO)
  end
end
