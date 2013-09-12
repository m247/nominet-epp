require 'helper'

class TestNominetHostDeleteRequest < Test::Unit::TestCase
  context 'NominetEPP::Host::Delete' do
    setup do
      @request = NominetEPP::Host::Delete.new('ns1.example.co.uk')
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end
    
    should 'have name' do
      assert_equal 'ns1.example.co.uk', xpath_find('//host:name')
    end
  end
end
