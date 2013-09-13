require 'helper'

class TestNominetContactCheckResponse < Test::Unit::TestCase
  context 'NominetEPP::Contact::Check' do
    setup do
      @check_response = NominetEPP::Contact::CheckResponse.new(load_response('contact/check'))
    end

    should 'be successful' do
      assert @check_response.success?
      assert_equal 1000, @check_response.code
    end

    should 'have message' do
      assert_equal 'Command completed successfully', @check_response.message
    end

    should 'list ioefwurfoveyrf9e as available' do
      assert @check_response.available?('ioefwurfoveyrf9e')
      assert !@check_response.unavailable?('ioefwurfoveyrf9e')
    end

    should 'list EAXXMK1FW0YZTABD as unavailable' do
      assert @check_response.unavailable?('EAXXMK1FW0YZTABD')
      assert !@check_response.available?('EAXXMK1FW0YZTABD')
    end
  end
end
