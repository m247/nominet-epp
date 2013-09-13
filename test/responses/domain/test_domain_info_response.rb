require 'helper'

class TestNominetDomainInfoResponse < Test::Unit::TestCase
  context 'NominetEPP::Domain::Info' do
    setup do
      @info_response = NominetEPP::Domain::InfoResponse.new(load_response('domain/info'))
    end

    should 'be successful' do
      assert @info_response.success?
      assert_equal 1000, @info_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @info_response.message
    end

    should 'have name' do
      assert_equal 'ophelia-testing.co.uk', @info_response.name
    end

    should 'have roid' do
      assert_equal '114112-UK', @info_response.roid
    end

    should 'have registrant' do
      assert_equal 'EAXXMK1FW0YZTABD', @info_response.registrant
    end

    should 'have nameservers' do
      expected = %w(ns1.ophelia-testing.co.uk)
      assert_equal expected, @info_response.nameservers
    end

    should 'have client_id' do
      assert_equal 'TESTING', @info_response.client_id
    end

    should 'have creator_id' do
      assert_equal 'psamathe@nominet.org.uk', @info_response.creator_id
    end

    should 'have created_date' do
      # 2012-09-13T00:09:32
      expected = Time.mktime(2012,9,13,0,9,32)
      assert_equal expected, @info_response.created_date
    end

    should 'have expiration_date' do
      # 2014-09-13T00:09:32
      expected = Time.mktime(2014,9,13,0,9,32)
      assert_equal expected, @info_response.expiration_date
    end

    should 'have first-bill' do
      assert_equal 'th', @info_response.first_bill
    end

    should 'have recur-bill' do
      assert_equal 'th', @info_response.recur_bill
    end

    should 'have DS information' do
      expected = { :key_tag      => '12345',
                   :alg          => '5',
                   :digest_type  => '1',
                   :digest       => '38EC35D5B3A34B44C39B38EC35D5B3A34B44C39B' }
     assert_equal [expected], @info_response.ds
    end
  end
end
