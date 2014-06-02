require 'helper'

class TestNominetDomainRenewRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Renew' do
    setup do
      @time    = Time.now.utc
      @request = NominetEPP::Domain::Renew.new('example.co.uk', @time, '2y')
      @xml     = prepare_request.to_xml
    end

    should 'validate against schema' do
      assert @xml.validate_schema(schema)
    end
  end
end
