$LOAD_PATH << File.dirname(__FILE__) + '/core_ext'
$LOAD_PATH << File.dirname(__FILE__) + '/elementor'

require 'rubygems'
require 'nokogiri'
require 'array'
require 'kernel'
require 'object'
require 'symbol'
require 'result'
require 'element_set'

module Elementor
  def elements(opts={}, &block)
    Result.new(self, opts, &block).dispatcher
  end
end