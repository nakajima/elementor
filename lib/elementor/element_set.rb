module Elementor
  class ElementSet < Array
    def with_text(str)
      select { |item| item.text.include?(str) }
    end
    
    def inspect
      map(&:text).inspect
    end
  end
end