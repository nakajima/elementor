require 'rubygems'
require 'nokogiri'
require 'nakajima'

module Elementor
  class NamerContext
    instance_methods.each { |m| undef_method(m) unless m =~ /^__/ }
    
    def initialize(namer)
      @namer = namer
    end
    
    def method_missing(sym, *args)
      @namer.element_names[sym] = *args
    end
  end
  
  class Namer
    def initialize(context, &block)
      @context = context
      block.call NamerContext.new(self)
    end
  
    def define_elements!
      element_names.each do |name, selector|
        @context.meta_def(name) { search(selector) }
      end
    end
    
    def element_names
      @element_names ||= { }
    end
  end
  
  def elements(opts={}, &block)
    opts[:from] ||= :body
    Nokogiri(send(opts[:from])).tap do |doc|
      Namer.new(doc, &block).define_elements!
    end
  end
end