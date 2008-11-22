module Elementor
  class ElementSet < Array
    attr_accessor :result, :selector
    
    def with_text(matcher)
      filter do |item|
        case matcher
        when Regexp then item.text =~ matcher
        when String then item.text.include?(matcher)
        end
      end
    end
    
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
    
    def inspect
      map(&:text).inspect
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