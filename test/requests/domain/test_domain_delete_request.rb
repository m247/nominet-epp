require 'helper'

class TestNominetDomainDeleteRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Delete' do
    setup do
      @request = NominetEPP::Domain::Delete.new('example.co.uk')
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
