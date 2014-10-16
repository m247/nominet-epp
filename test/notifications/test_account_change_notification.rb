require 'helper'

class TestNominetAccountChangeNotification < Test::Unit::TestCase
  context 'NominetEPP::Notifications::AccountChange' do
    setup do
      @notification =
        NominetEPP::Notification.new(
          load_response('notifications/account-change'))
    end
    subject { @notification }

    should 'have type' do
      assert_equal :account_change, subject.type
    end

    should 'have contact id' do
      assert_equal 'CMyContactID', subject.id
    end
    should 'have roid' do
      assert_equal '548965487-UK', subject.roid
    end
  end
end
