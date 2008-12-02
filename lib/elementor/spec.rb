module Spec
  module Matchers
    class Have
      def with_text(*args)
        @args ||= []
        @args << proc { |set| set.with_text(*args) }
        self
      end
      
      alias_method :text, :with_text
      
      def with_attrs(options={})
        @args ||= []
        @args << proc { |set| set.with_attrs(options) }
        self
      end
      
      alias_method :attrs, :with_attrs
    end
  end
end