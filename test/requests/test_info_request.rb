require 'helper'

class TestNominetInfoRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Info' do
    setup do
      @request = NominetEPP::Domain::Info.new('example.co.uk')
      @xml     = prepare_request.to_xml
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end
  end
end
