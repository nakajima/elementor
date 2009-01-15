module Elementor
  class InvalidParser < ArgumentError ; end

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
          @this.doc_ready!
          [@this, @this.doc].each do |context|
            next unless context.respond_to?(sym)
            return context.send(sym, *args, &block)
          end
          super # raise NoMethodError if no context can handle
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
        parser = opts[:as] ? opts[:as].to_s : nil
        @doc ||= case parser
                 when nil, 'html' then Nokogiri::HTML(html)
                 when 'xml' then Nokogiri::XML(html)
                 else raise InvalidParser.new("Nokogiri cannot parse as '#{opts[:as]}'. Please request :xml or :html.")
                 end
      end
    end
    
    # Indicates whether or not the dispatcher has received messages,
    # meaning the content method can be called.
    def doc_ready?
      @doc_ready
    end
    
    def doc_ready!
      @doc_ready = true
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
        metaclass.class_eval(<<-END, __FILE__, __LINE__)
          def #{name}(*filters, &block)
            make_element_set(#{name.inspect}, #{selector.inspect}, *filters, &block)
          end
        END
      end
    end
    
    def make_element_set(name, selector, *filters, &block)
      set = ElementSet.new(doc, scope(filters).search(selector))
      set.result = self
      set.selector = selector
      set = filters.empty? ? set : filters.inject(set) { |result, fn| fn[result] }
      set = block.call(set) if block_given?
      set
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
