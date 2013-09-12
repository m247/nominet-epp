require 'helper'

class TestNominetContactInfoRequest < Test::Unit::TestCase
  context 'NominetEPP::Contact::Info' do
    setup do
      @request = NominetEPP::Contact::Info.new('sh8013')
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end
    
    should 'have name' do
      assert_equal 'sh8013', xpath_find('//contact:id')
    end
  end
end
