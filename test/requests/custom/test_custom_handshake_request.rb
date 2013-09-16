require 'helper'

class TestNominetCustomHandshakeRequest < Test::Unit::TestCase
  context 'NominetEPP::Custom::Handshake' do
    context 'without registrant' do
      setup do
        @request = NominetEPP::Custom::Handshake.new('123456')
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have caseId' do
        assert_equal '123456', xpath_find('//h:caseId')
      end
    end
    context 'with registrant' do
      setup do
        @request = NominetEPP::Custom::Handshake.new('123456', 'sh8013')
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have caseId' do
        assert_equal '123456', xpath_find('//h:caseId')
      end

      should 'have registrant' do
        assert_equal 'sh8013', xpath_find('//h:registrant')
      end
    end
  end
end
