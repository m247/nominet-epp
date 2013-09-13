require 'helper'

class TestNominetDomainUnrenewResponse < Test::Unit::TestCase
  context 'NominetEPP::Domain::Unrenew' do
    setup do
      @unrenew_response = NominetEPP::Domain::UnrenewResponse.new(load_response('domain/unrenew'))
    end

    should 'be successful' do
      assert @unrenew_response.success?
      assert_equal 1000, @unrenew_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @unrenew_response.message
    end

    should 'have expiry date for example.co.uk' do
      expect = Time.gm(2013,1,2,11,56,40)
      exDate = @unrenew_response.expires?('example.co.uk')

      assert_equal expect, exDate
    end

    should 'have expiry date for example2.co.uk' do
      expect = Time.gm(2013,1,2,11,56,40)
      exDate = @unrenew_response.expires?('example2.co.uk')

      assert_equal expect, exDate
    end
  end
end
