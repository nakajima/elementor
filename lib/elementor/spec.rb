module Spec
  module Matchers
    class Have
      def with_text(*args)
        @args = []
        @args << proc { |set| set.with_text(*args) }
        self
      end
    end
  end
end