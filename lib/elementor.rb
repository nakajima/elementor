$LOAD_PATH << File.dirname(__FILE__) + '/core_ext'
$LOAD_PATH << File.dirname(__FILE__) + '/elementor'

require 'rubygems'
require 'nokogiri'
require 'nakajima'
require 'kernel'
require 'result'
require 'element_set'

module Elementor
  def elements(opts={}, &block)
    opts[:from] ||= :body
    doc = Nokogiri(send(opts[:from]))
    namer = Result.new(doc, &block)
    namer.define_elements!
    namer.dispatcher
  end
end