# frozen_string_literal: true

require_relative "pay_rb/version"
require_relative "pay_rb/client"

require 'faraday'
require 'active_support/core_ext/string/inflections'

module PayRb
  class Error < StandardError; end
end
