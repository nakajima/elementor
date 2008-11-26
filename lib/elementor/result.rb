module Elementor
  class Result
    attr_writer :doc_ready
    attr_reader :context, :opts
    
    def initialize(context, opts={}, &block)
      @opts = opts
      @context = context
      @doc_ready = false
      block.call(naming_context)
      define_elements!
    end
    
    # Allows for the parsing of raw markup that doesn't come
    # from the :from option.
    def parse!(markup)
      doc(markup)
    end
    
    # Returns a blank slate object that delegates to either an
    # instance of Result or the original Nokogiri doc.
    def dispatcher
      @dispatcher ||= blank_context(:this => self) do
        def method_missing(sym, *args, &block)
          @this.doc_ready = true
          @this.try(sym, *args, &block) || @this.doc.try(sym, *args, &block) || super
        end
      end
    end

    # The list of name/selector pairs you specify in the
    # elements block.
    def element_names
      @element_names ||= { }
    end

    # Returns the raw Nokogiri doc once a method has been called
    # on the dispatcher. Up until that point, returns nil.
    def doc(markup=nil)
      if html = markup || content
        @doc = nil if markup
        @doc ||= Nokogiri(html)
      end
    end
    
    # Indicates whether or not the dispatcher has received messages,
    # meaning the content method can be called.
    def doc_ready?
      @doc_ready
    end

    private
    
    # Blank slate context for defining element names.
    def naming_context
      @naming_context ||= blank_context(:this => self) do
        def method_missing(sym, *args)
          @this.element_names[sym] = *args
        end
      end
    end
    
    # Takes element names and defines methods that return ElementSet
    # objects with can be chained and filtered.
    def define_elements!
      element_names.each do |name, selector|
        meta_def(name) do |*filters|
          set = ElementSet.new
          set.scope = scope(filters)
          set.result = self
          set.selector = selector
          filters.each { |fn| fn[set] }
          set
        end
      end
    end
    
    # Enables the chaining of element selector methods to only search
    # within the scope of a certain ElementSet.
    def scope(filters)
      scope = filters.first.is_a?(Proc) ? nil : filters.shift
      scope || doc
    end
    
    def content
      return unless doc_ready?
      @content ||= context.send(opts[:from] || :body)
    end
  end
end