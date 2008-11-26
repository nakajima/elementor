class Array
  def extract_options!
    last.is_a?(Hash) ? pop : { }
  end unless [].respond_to?(:extract_options!)
  
  def extract_filters!
    inject([]) do |result, fn|
      result << delete(fn) if fn.is_a?(Elementor::Filter)
      result
    end
  end
  
  def extract_scope!
    scope = detect { |fn| fn.is_a?(Nokogiri::XML::NodeSet) }
    delete(scope)
  end
end