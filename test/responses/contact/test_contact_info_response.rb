require 'helper'

class TestNominetContactInfoResponse < Test::Unit::TestCase
  context 'NominetEPP::Contact::Info' do
    setup do
      @info_response = NominetEPP::Contact::InfoResponse.new(load_response('contact/info'))
    end

    should 'be successful' do
      assert @info_response.success?
      assert_equal 1000, @info_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @info_response.message
    end

    should 'have id' do
      assert_equal 'EAXXMK1FW0YZTABD', @info_response.id
    end

    should 'have name' do
      assert_equal 'EAXXMK1FW0YZTABD', @info_response.name
    end

    should 'have roid' do
      assert_equal '50643904-UK', @info_response.roid
    end

    should 'have client_id' do
      assert_equal 'TESTING', @info_response.client_id
    end

    should 'have creator_id' do
      assert_equal 'psamathe@nominet.org.uk', @info_response.creator_id
    end

    should 'have created_date' do
      # 2013-09-13T00:09:32
      expected = Time.mktime(2013,9,13,0,9,32)
      assert_equal expected, @info_response.created_date
    end

    should 'have trad-name' do
      assert_equal 'Simple Registrant Trading Ltd', @info_response.trad_name
    end

    should 'have type' do
      assert_equal 'LTD', @info_response.type
    end

    should 'have co-no' do
      assert_equal '12345678', @info_response.co_no
    end

    should 'have opt-out' do
      assert_equal false, @info_response.opt_out
    end
  end
end
