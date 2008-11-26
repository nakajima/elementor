module Elementor
  # ElementSet objects wrap a Nokogiri #search result and
  # add additional functionality such as chained filtering.
  class ElementSet
    instance_methods.each { |m| undef_method(m) unless m =~ /__/ }
    
    attr_accessor :result, :selector, :scope
    
    # A simple filter for selecting only elements with content
    # that either includes a String passed in, or matches a Regexp.
    def with_text(matcher)
      filter do |item|
        case matcher
        when Regexp then item.text =~ matcher
        when String then item.text.include?(matcher)
        end
      end
    end
    
    # Attribute filtering using hashes. See the specs for examples.
    def with_attrs(options={})
      filter do |item|
        options.all? do |key, value|
          case value
          when Regexp then item[key.to_s] =~ value
          when String then item[key.to_s] == value
          end
        end
      end
    end

    def method_missing(sym, *args, &block)
      filtered_nodes.try(sym, *args, &block) || result.try(sym, doc, *args) || super
    end
    
    def respond_to?(sym)
      filtered_nodes.respond_to?(sym) || result.respond_to?(sym) || super
    end
    
    def filters
      @filters ||= []
    end
    
    private
    
    def doc
      scope.search(selector)
    end
    
    def filtered_nodes
      doc.to_a.flatten.tap do |set|
        set.each do |node|
          set.delete(node) unless filters.all? { |fn| fn.call(node) }
        end
      end.compact
    end
    
    def filter(&block)
      filters.push(block)
      filtered_nodes
      return self
    end
  end
end