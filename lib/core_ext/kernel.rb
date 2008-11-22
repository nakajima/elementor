module Kernel
  def blank_context(*args, &block)
    ivars = args.extract_options!
    
    args.push(/(^__)|instance_/)
    
    klass = Class.new do
      instance_methods.each do |m|
        undef_method(m) unless args.any? { |pattern| m =~ pattern }
      end
    end
    
    klass.class_eval(&block) if block_given?
    instance = klass.new
    ivars.each { |key, value| instance.instance_variable_set("@#{key}", value) }
    instance
  end
end