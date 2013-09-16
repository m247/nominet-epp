require 'helper'

class TestNominetCustomHandshakeResponse < Test::Unit::TestCase
  context 'NominetEPP::Custom::Handshake' do
    setup do
      @handshake_response = NominetEPP::Custom::HandshakeResponse.new(load_response('custom/handshake'))
    end

    should 'be successful' do
      assert @handshake_response.success?
      assert_equal 1000, @handshake_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @handshake_response.message
    end

    should 'have caseId' do
      assert_equal '6', @handshake_response.case_id
    end

    should 'have domains' do
      expected = %w(example1.co.uk example2.co.uk)
      assert_equal expected, @handshake_response.domains
    end
  end
end
