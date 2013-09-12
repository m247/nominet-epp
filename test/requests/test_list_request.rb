require 'helper'

class TestNominetListRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Info' do
    context 'expiry' do
      setup do
        @request = NominetEPP::Domain::List.new('expiry', '2013-09')
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end
      
      should 'have expiry element' do
        assert xpath_exists?('//l:expiry')
      end
      should 'have current date for expiry' do
        assert_equal '2013-09', xpath_find('//l:expiry')
      end
    end
    context 'registrations' do
      setup do
        @request = NominetEPP::Domain::List.new('registration', '2013-09')
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end
      
      should 'have month element' do
        assert xpath_exists?('//l:month')
      end
      should 'have current date for month' do
        assert_equal '2013-09', xpath_find('//l:month')
      end
    end
  end
end
