module Elementor

  module NodeSet
    def self.included(base)
      base.class_eval do
        attr_accessor :node_set
      end
    end

    def initialize(document, array)
      @node_set = Nokogiri::XML::NodeSet.new(document, array)
    end

    def select(&block)
      @node_set.select &block
    end

    def replace(array)
      @node_set = Nokogiri::XML::NodeSet.new(@node_set.document, array)
    end

    def respond_to?(sym)
      super || @node_set.respond_to?(sym)
    end

    # Delegates non-ElementSet methods to the NodeSet
    def method_missing(sym, *args, &block)
      if @node_set.respond_to?(sym)
        @node_set.send(sym, *args, &block)
      else
        super
      end
    end
  end

  # ElementSet objects wrap a Nokogiri #search result and
  # add additional functionality such as chained filtering.
  class ElementSet

    include NodeSet

    attr_accessor :result, :selector
    
    # A simple filter for selecting only elements with content
    # that either includes a String passed in, or matches a Regexp.
    def with_text(matcher)
      filter do |item|
        case matcher
        when Regexp then item.text =~ matcher
        when String then item.text.include?(matcher)
        else item.text.include?(matcher.to_s)
        end
      end
    end
    
    alias_method :text, :with_text
    
    # Attribute filtering using hashes. See the specs for examples.
    def with_attrs(options={})
      filter do |item|
        options.all? do |key, value|
          case value
          when Regexp then item[key.to_s] =~ value
          when String then item[key.to_s] == value
          else item[key.to_s] == value.to_s
          end
        end
      end
    end
    
    alias_method :attrs, :with_attrs

    def method_missing(sym, *args, &block)
      result.respond_to?(sym) ? result.send(sym, self, *args) : super
    end
    
    def respond_to?(sym)
      result.respond_to?(sym) || super
    end
    
    private
    
    def doc
      result.doc.search(selector)
    end
    
    def filter(&block)
      replace(select(&block)) ; return self
    end
  end
end
