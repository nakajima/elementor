module Elementor
  class Result
    def initialize(context, &block)
      @context = context
      block.call(naming_context)
    end
    
    def naming_context
      @naming_context ||= blank_context(:this => self) do
        def method_missing(sym, *args)
          @this.element_names[sym] = *args
        end
      end
    end

    def dispatcher
      @dispatcher ||= blank_context(:this => self, :context => @context) do
        def method_missing(sym, *args, &block)
          @this.try(sym, *args, &block) || @context.try(sym, *args, &block) || super
        end
      end
    end
  
    def define_elements!
      element_names.each do |name, selector|
        meta_def(name) do |*mutators|
          set = ElementSet.new(@context.search(selector).to_ary)
          mutators.empty? ? set : mutators.inject(set) { |result, fn| fn[result] }
        end
      end
    end
    
    def element_names
      @element_names ||= { }
    end
  end
end