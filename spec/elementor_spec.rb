require 'spec/spec_helper'

HTML = Nokogiri::HTML::Builder.new {
  html {
    head { title("This is the title") }
    body {
      h1("A header")
      div(:id => "tag-cloud") {
        a(:href => '#foo') { text "Foo" }
        a(:href => '#bar') { text "Bar" }
      }
    }
  }
}.doc.to_html

describe Elementor do
  include Elementor
  
  attr_reader :body, :result
  
  before(:each) do
    @body = HTML.dup
  end
  
  describe "the html" do
    it "has tags" do
      Nokogiri(body).search('#tag-cloud a').should have(2).nodes
    end
    
    it "has a header" do
      Nokogiri(body).search('h1').should have(1).nodes
    end
  end
  
  describe "the DSL" do
    context "without elements defined" do
      it "can not find tags" do
        proc {
          @result.should have(2).tags
        }.should raise_error
      end
    end
    
    context "with elements defined" do
      before(:each) do
        @result = elements(:from => :body) do |tag|
          tag.header "h1"
          tag.tags "#tag-cloud a"
        end
      end
      
      it "can find tags" do
        result.should have(1).header
        result.should have(2).tags
      end
      
      describe ":from option" do
        before do
          meta_def(:source) { HTML.dup }
          
          @result = elements(:from => :body) do |tag|
            tag.header "h1"
            tag.tags "#tag-cloud a"
          end
        end
        
        it "determines which method should be called to get the markup" do
          result.should have(1).header
          result.should have(2).tags
        end
      end
    end
  end
end