class Symbol
  def to_proc
    Proc.new do |target|
      target.send(self)
    end
  end
end unless :test.respond_to?(:to_proc)