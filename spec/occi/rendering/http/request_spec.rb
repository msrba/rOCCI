require "rspec"
require 'logger'
require 'Hashie'

require 'occi/rendering/http/Request'

$log = Logger.new(NIL)

module OCCI
  module Rendering
    module HTTP
      describe Request do
        it "parses headers successfully" do
          ATTRIBUTE = { :mutable => true, :required => false, :type => { :string => {} }, :default => '' }
          #To change this template use File | Settings | File Templates.
          header = Hash.new
          header['HTTP_CATEGORY'] = %Q{my_tag;
          scheme="http://example.com/tags#";
          class="mixin";
          title="My Tag How's your quote's escaping \\" ?";
          rel="http://schemas.ogf.org/occi/infrastructure#resource_tpl";
          attributes="com.example.tags.my_tag" }
          mixins = Request.parse_header_mixins(header)
          mixins.first.should  be_kind_of(Hashie::Mash)
          mixins.first.term.should == 'my_tag'
          mixins.first.scheme.should == 'http://example.com/tags#'
          mixins.first.title.should == %Q{My Tag How's your quote's escaping \\" ?}
          mixins.first.related == 'http://schemas.ogf.org/occi/infrastructure#resource_tpl'
          mixins.first.attributes.com.example.tags.my_tag == ATTRIBUTE
        end

        it "parses plain text successfully" do

        end

        it "parses json successfully" do

        end
      end
    end
  end
end