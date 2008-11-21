require 'spec/spec_helper'

HTML = Nokogiri::HTML::Builder.new {
  html {
    head { title("This is the title") }
    body {
      h1("A header")
      div(:id => "tag-cloud") {
        a(:href => '#foo') { text "Foo" }
        a(:href => '#bar') { text "Bar" }
        a(:href => '#fizz') { text "Fizz" }
        a(:href => '#buzz') { text "Buzz" }
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
      Nokogiri(body).search('#tag-cloud a').should have(4).nodes
    end
    
    it "has a header" do
      Nokogiri(body).search('h1').should have(1).nodes
    end
  end
  
  describe "the DSL" do
    context "without elements defined" do
      it "can not find tags" do
        proc {
          @result.should have(4).tags
        }.should raise_error
      end
    end
    
    describe "error handling" do
      context  "before methods have been called on result object" do
        it "swallows errors" do
          view = Class.new { def render; send(:foo!) end }.new
        
          meta_def(:whoops!) { view.render }
    
          proc {
            @result = elements(:from => :whoops!) do |tag|
              tag.header "h1"
              tag.tags "#tag-cloud a"
            end
    
            @result.instance_variable_get("@this").doc
          }.should_not raise_error
        end
      end
      
      context "after methods have been called on result object" do
        it "re-raises errors that occur when :from blows up" do
          view = Class.new { def render; send(:foo!) end }.new
        
          meta_def(:whoops!) { view.render }
    
          proc {
            @result = elements(:from => :whoops!) do |tag|
              tag.header "h1"
              tag.tags "#tag-cloud a"
            end
    
            result.should have(0).header
          }.should raise_error(NoMethodError)
        end
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
        result.should have(4).tags
      end
      
      it "can still use old Nokogiri traversal methods" do
        result.search('#tag-cloud a').should have(4).nodes
        result.search('h1').should have(1).nodes
      end
      
      it "creates more readable inspect" do
        result.header.inspect.should == "[\"A header\"]"
      end
      
      describe ":from option" do
        it "determines which method should be called to get the markup" do
          @result = elements(:from => :body) do |tag|
            tag.header "h1"
            tag.tags "#tag-cloud a"
            tag.bodies "body"
          end
          
          result.should have(1).header
          result.should have(4).tags
        end
        
        it "works when the HTML isn't present until after the #elements call" do
          mock(self).deferred_source.once.returns(HTML.dup)
          
          @result = elements(:from => :deferred_source) do |tag|
            tag.header "h1"
            tag.tags "#tag-cloud a"
            tag.bodies "body"
          end
          
          result.should have(1).header
          result.should have(4).tags
        end
      end
      
      describe "#with_text" do
        it "limits results by text" do
          result.tags.with_text("Foo").should have(1).node
        end
        
        describe "as an rspec matcher" do
          it "works with no matches" do
            result.should have(0).tags.with_text("Wee")
          end
          
          it "works with 1 match" do
            result.should have(1).tags.with_text("Foo")
          end
          
          it "works with many matches" do
            result.should have(2).tags.with_text("zz")
          end
        end
      end
      
      describe "#parse!" do
        it "parses new markup" do
          result.should have(4).tags
          result.parse!(%(<h1>Fred</h1>))
          result.should have(0).tags
          result.should have(1).header.with_text("Fred")
        end
      end
    end
  end
end