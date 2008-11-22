class Array
  def extract_options!
    last.is_a?(Hash) ? pop : { }
  end
end unless [].respond_to?(:extract_options!)