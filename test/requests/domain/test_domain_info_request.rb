require 'helper'

class TestNominetDomainInfoRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Info' do
    setup do
      @request = NominetEPP::Domain::Info.new('example.co.uk')
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end
    
    should 'have name' do
      assert_equal 'example.co.uk', xpath_find('//domain:name')
    end
  end
end
