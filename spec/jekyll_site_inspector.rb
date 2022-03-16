# frozen_string_literal: true

require "jekyll"
require_relative "../lib/jekyll_site_inspector"

RSpec.describe(Jekyll) do
  include Jekyll
  require "logger"

  it "is created properly" do
    # expect(log.level).to eq(Logger::INFO)
  end
end
