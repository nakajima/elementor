require 'rubygems'
require 'spec'
require 'rr'

require File.dirname(__FILE__) + '/../lib/elementor'
require File.dirname(__FILE__) + '/../lib/elementor/spec'

Spec::Runner.configure { |c| c.mock_with(:rr) }