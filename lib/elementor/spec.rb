module Spec
  module Matchers
    class Have
      def with_text(*args)
        @args ||= []
        @args << proc { |set| set.with_text(*args) }
        self
      end
      
      def with_attrs(options={})
        @args ||= []
        @args << proc { |set| set.with_attrs(options) }
        self
      end
    end
  end
end