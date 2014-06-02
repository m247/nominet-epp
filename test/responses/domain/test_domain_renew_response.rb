require 'helper'

class TestNominetDomainRenewResponse < Test::Unit::TestCase
  context 'NominetEPP::Domain::Renew' do
    setup do
      @renew_response = NominetEPP::Domain::RenewResponse.new(load_response('domain/renew'))
    end

    should 'be successful' do
      assert @renew_response.success?
      assert_equal 1000, @renew_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @renew_response.message
    end

    should 'have name example.co.uk' do
      assert_equal 'example.co.uk', @renew_response.name
    end

    should 'have new expiration date' do
      expected = Time.gm(2010,12,12,13,04,46)
      assert_equal expected, @renew_response.expiration_date
    end
  end
end
