require 'helper'

class TestNominetCustomTagListRequest < Test::Unit::TestCase
  context 'NominetEPP::Custom::TagList' do
    setup do
      @schema  = load_schema('nom-root-tag-1.0')
      @request = NominetEPP::Custom::TagList.new
      @xml     = prepare_request.to_xml

      namespaces_from_request
    end

    should 'validate against schema' do
      assert @xml.validate_schema(@schema)
    end
    
    should 'have tag:list element' do
      assert xpath_exists?('//tag:list')
    end
  end
end
