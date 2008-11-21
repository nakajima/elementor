module Elementor
  class ElementSet < Array
    def with_text(str)
      ElementSet.new(select { |item| item.text.include?(str) })
    end
    
    def with_attrs(options={})
      ElementSet.new(select { |item|
        options.all? { |key, value| item[key.to_s] == value }
      })
    end
    
    def inspect
      map(&:text).inspect
    end
  end
end