require 'helper'

class TestNominetContactReleaseResponse < Test::Unit::TestCase
  context 'NominetEPP::Contact::Release' do
    setup do
      @release_response = NominetEPP::Contact::ReleaseResponse.new(load_response('contact/release'))
    end

    should 'be successful' do
      assert @release_response.success?
      assert_equal 1000, @release_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @release_response.message
    end
  end
end
