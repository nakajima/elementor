module Elementor
  class Result
    attr_writer :doc_ready
    attr_reader :context, :opts
    
    def initialize(context, opts={}, &block)
      @opts = opts
      @context = context
      @doc_ready = false
      block.call(naming_context)
    end
    
    def parse!(markup)
      doc(markup)
    end
    
    def naming_context
      @naming_context ||= blank_context(:this => self) do
        def method_missing(sym, *args)
          @this.element_names[sym] = *args
        end
      end
    end

    def dispatcher
      @dispatcher ||= blank_context(:this => self) do
        def method_missing(sym, *args, &block)
          @this.doc_ready = true
          @this.try(sym, *args, &block) || @this.doc.try(sym, *args, &block) || super
        end
      end
    end
  
    def define_elements!
      element_names.each do |name, selector|
        meta_def(name) do |*mutators|
          set = ElementSet.new(doc.search(selector).to_ary)
          mutators.empty? ? set : mutators.inject(set) { |result, fn| fn[result] }
        end
      end
    end
    
    def element_names
      @element_names ||= { }
    end
    
    def doc(markup=nil)
      if html = markup || content
        @doc = nil if markup
        @doc ||= Nokogiri(html)
      end
    end
    
    def content
      return unless doc_ready?
      @content ||= context.send(opts[:from] || :body)
    end
    
    def doc_ready?
      @doc_ready
    end
  end
end