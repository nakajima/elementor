module Elementor
  class Filter
    def initialize(&block)
      @block = block
    end
    
    def to_proc
      @block
    end
  end
end