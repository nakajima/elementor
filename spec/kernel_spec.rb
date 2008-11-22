require 'spec/spec_helper'

describe "blank_context" do
  attr_reader :klass, :object
  
  before(:each) do
    @klass = Class.new do
      def unknown
        @unknown ||= []
      end
      
      def blank_eval(&block)
        blank.instance_eval(&block)
      end
      
      def blank
        @blank ||= blank_context(:context => self) do
          def method_missing(sym, *args, &block)
            @context.unknown.push(sym)
          end
        end
      end
    end
    
    @object = @klass.new
  end
  
  it "allows a white list regex" do
    proc {
      context = blank_context(/=/)
      context == context
      context === context
    }.should_not raise_error
  end
  
  it "assigns instance variables in blank class from options" do
    object.blank.instance_eval { @context }.should == object
  end
  
  it "allows methods to be called through blank context" do
    object.blank_eval { hello }
    object.unknown.should == [:hello]
  end
end