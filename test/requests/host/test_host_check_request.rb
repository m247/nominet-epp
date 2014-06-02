require 'helper'

class TestNominetHostCheckRequest < Test::Unit::TestCase
  context 'NominetEPP::Host::Check' do
    setup do
      @request = NominetEPP::Host::Check.new('ns1.example.co.uk', 'ns2.example.me.uk')
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end

    should 'include names' do
      names = []
      xpath_each('//host:name') do |node|
        names << node.content.strip
      end

      assert_equal ['ns1.example.co.uk', 'ns2.example.me.uk'], names
    end
  end
end
