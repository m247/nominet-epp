require 'helper'

class TestNominetDomainCheckRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Check' do
    setup do
      @request = NominetEPP::Domain::Check.new('example.co.uk', 'example.me.uk')
      @xml     = prepare_request.to_xml
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end
  end
end
