require 'helper'

class TestNominetDomainCheckResponse < Test::Unit::TestCase
  context 'NominetEPP::Domain::Check' do
    setup do
      @check_response = NominetEPP::Domain::CheckResponse.new(load_response('domain/check'))
    end

    should 'be successful' do
      assert @check_response.success?
      assert_equal 1000, @check_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @check_response.message
    end

    should 'list adriana-available.co.uk as available' do
      assert @check_response.available?('adriana-available.co.uk')
      assert !@check_response.unavailable?('adriana-available.co.uk')
    end

    should 'list adriana-unavailable.co.uk as unavailable' do
      assert @check_response.unavailable?('adriana-unavailable.co.uk')
      assert !@check_response.available?('adriana-unavailable.co.uk')
    end

    should 'have an abuse limit' do
      assert_equal 49997, @check_response.abuse_limit
    end
  end
end
