module Kernel
  def blank_context(ivars={}, &block)
    klass = Class.new do
      instance_methods.each { |m| undef_method(m) unless m =~ /^(__|instance_|meta)/ }
    end
    
    klass.class_eval(&block)
    instance = klass.new
    ivars.each { |key, value| instance.instance_variable_set("@#{key}", value) }
    instance
  end
end