require 'helper'

class TestNominetDomainRenewRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Renew' do
    context 'normal renewal' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Domain::Renew.new('example.co.uk', @time, '2y')
        @xml     = prepare_request.to_xml
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end
    end
    context 'period = 10y' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Domain::Renew.new('example.co.uk', @time, '10y')
        @xml     = prepare_request.to_xml
        
        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end
      
      should 'have period elemement of 10y' do
        assert_equal '10', xpath_find('//domain:period')
        assert_equal 'y', xpath_find('//domain:period/@unit')
      end
    end
    context 'period = 120m' do
      should 'raise ArgumentError' do
        assert_raises ArgumentError do
          NominetEPP::Domain::Renew.new('example.co.uk', Time.now, '120m')
        end
      end
    end
  end
end
