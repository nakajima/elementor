require File.dirname(__FILE__) + '/spec_helper'

HTML = Nokogiri::HTML::Builder.new {
  html {
    head { title("This is the title") }
    body {
      h1("A header")
      div(:class => "tag-cloud", :rel => "other") {
        a(:href => '#foo', :class => 'tag even') { text "Foo" }
        a(:href => '#bar', :class => 'tag') { text "Bar" }
      }
      div(:id => "user-links") {
        h1("User Link Section")
        div(:class => "tag-cloud") {
          a(:href => '#fizz', :class => 'tag even') { text "Fizz" }
          a(:href => '#buzz', :class => 'tag') { text "Buzz" }
        }
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
      Nokogiri(body).search('.tag-cloud a').should have(4).nodes
    end
    
    it "has a headers" do
      Nokogiri(body).search('h1').should have(2).nodes
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
    
    context "with elements defined" do
      before(:each) do
        @result = elements(:from => :body) do |tag|
          tag.headers "h1"
          tag.tag_clouds ".tag-cloud"
          tag.tags "a.tag"
          tag.user_links "#user-links"
        end
      end
      
      it "can find tags" do
        result.should have(2).headers
        result.should have(4).tags
      end
      
      it "can still use old Nokogiri traversal methods" do
        result.search('.tag-cloud a').should have(4).nodes
        result.search('h1').should have(2).nodes
      end
      
      describe "chaining selectors" do
        it "can chain selector aliases" do
          result.user_links.headers.should have(1).node
          result.user_links.tags.should have(2).nodes
        end
        
        it "works with with_text filter" do
          result.user_links.tags.with_text('Fizz').should have(1).node
        end
        
        it "works with with_attrs filter" do
          result.user_links.tags.with_attrs(:class => /even/).should have(1).node          
        end
        
        describe "as an rspec matcher" do
          it "works with no matches" do
            result.tags.should have(0).user_links
          end

          it "works with 1 match" do
            result.user_links.should have(1).headers
          end
          
          it "works with many matches" do
            result.user_links.should have(2).tags
          end
          
          it "allows chaining" do
            result.user_links.should have(1).tags.with_attrs(:class => /even/).with_text('Fizz')
          end
        end
      end
      
      describe ":from option" do
        it "determines which method should be called to get the markup" do
          meta_eval { alias_method :other_body, :body }
          
          @result = elements(:from => :other_body) do |tag|
            tag.headers "h1"
            tag.tags ".tag-cloud a"
            tag.user_links "#user-links"
          end
          
          result.should have(2).headers
          result.should have(4).tags
        end
        
        it "works when the HTML isn't present until after the #elements call" do
          mock(self).deferred_source.once.returns(HTML.dup)
          
          @result = elements(:from => :deferred_source) do |tag|
            tag.headers "h1"
            tag.tags ".tag-cloud a"
            tag.bodies "body"
          end
          
          result.should have(2).headers
          result.should have(4).tags
        end
      end
      
      describe "filters" do
        describe "#with_text" do
          it "limits results by text" do
            result.tags.with_text("Foo").should have(1).node
          end
          
          it "limits results by regex" do
            result.tags.with_text(/foo|bar/i).should have(2).nodes
          end
          
          it "allows chaining with other filters" do
            result.tags.with_text('zz').with_attrs(:class => /even/).should have(1).node
          end
          
          it "allows chaining with selector aliases" do
            result.tag_clouds.with_text('Fizz').tags.should have(2).nodes
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
            
            it "allows chaining" do
              result.should have(1).tags.with_text("zz").with_attrs(:class => /even/)
            end
          end
        end
        
        describe "#with_attrs" do
          context "using string values" do
            it "limits results by one attribute" do
              result.tags.with_attrs(:href => '#foo').should have(1).node
              result.tags.with_attrs(:class => "tag even").should have(2).nodes
            end
          
            it "limits results by multiple attributes" do
              result.tags.with_attrs(:class => /even/, :href => '#foo').should have(1).node
            end
          end
          
          context "using regex values" do
            it "limits results by one attribute" do
              result.tags.with_attrs(:href => /#(foo|bar)/).should have(2).node
            end
          
            it "limits results by multiple attributes" do
              result.tags.with_attrs(:class => /even/, :href => /#(foo|bar)/).should have(1).node
            end
          end
          
          it "allows chaining with other filters" do
            result.tags.with_attrs(:class => /even/).with_text('Fizz').should have(1).node
          end
          
          it "allows chaining with selector aliases" do
            result.tag_clouds.with_attrs(:rel => 'other').tags.should have(2).nodes
          end
          
          describe "as an rspec matcher" do
            it "works with no matches" do
              result.should have(0).tags.with_attrs(:href => '#Wee')
            end

            it "works with 1 match" do
              result.should have(1).tags.with_attrs(:href => '#foo')
            end

            it "works with many matches" do
              result.should have(2).tags.with_attrs(:class => /even/)
            end
            
            it "allows chaining" do
              result.should have(1).tags.with_attrs(:class => /even/).with_text('Fizz')
            end
          end
        end
      end
      describe "error handling" do
        context  "before methods have been called on result object" do
          it "swallows errors" do
            view = Class.new { def render; send(:foo!) end }.new

            meta_def(:whoops!) { view.render }

            proc {
              @result = elements(:from => :whoops!) do |tag|
                tag.headers "h1"
                tag.tags ".tag-cloud a"
                tag.user_links "#user-links"
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
                tag.headers "h1"
                tag.tags ".tag-cloud a"
                tag.user_links "#user-links"
              end

              result.should have(0).headers
            }.should raise_error(NoMethodError)
          end
        end
      end
      
      describe "#parse!" do
        it "parses new markup" do
          result.should have(4).tags
          result.parse!(%(<h1>Fred</h1>))
          result.should have(0).tags
          result.should have(1).headers.with_text("Fred")
        end
      end
    end
  end
end