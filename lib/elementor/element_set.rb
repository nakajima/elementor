module Elementor
  # ElementSet objects wrap a Nokogiri #search result and
  # add additional functionality such as chained filtering.
  class ElementSet < Array
    attr_accessor :result, :selector
    
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
      result.try(sym, doc, *args) || super
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