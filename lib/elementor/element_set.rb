module Elementor
  class ElementSet < Array
    attr_accessor :result, :selector
    
    def with_text(matcher)
      replace(select { |item|
        case matcher
        when Regexp then item.text =~ matcher
        when String then item.text.include?(matcher)
        end
      }) ; self
    end
    
    def with_attrs(options={})
      replace(select { |item|
        options.all? { |key, value|
          case value
          when Regexp then item[key.to_s] =~ value
          when String then item[key.to_s] == value
          end
        }
      }) ; self
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
    
    def doc
      result.doc.search(selector)
    end
  end
end