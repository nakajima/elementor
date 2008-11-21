module Elementor
  class ElementSet < Array
    attr_accessor :result, :selector
    
    def with_text(str)
      replace(select { |item|
        item.text.include?(str)
      }) ; self
    end
    
    def with_attrs(options={})
      replace(select { |item|
        options.all? { |key, value| item[key.to_s] == value }
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