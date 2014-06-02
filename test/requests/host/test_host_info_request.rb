require 'helper'

class TestNominetHostInfoRequest < Test::Unit::TestCase
  context 'NominetEPP::Host::Info' do
    setup do
      @request = NominetEPP::Host::Info.new('ns1.example.co.uk')
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
