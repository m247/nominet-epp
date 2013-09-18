require 'helper'

class TestNominetContactDeletedNotification < Test::Unit::TestCase
  context 'NominetEPP::Notifications::ContactDeleted' do
    setup do
      @notification =
        NominetEPP::Notification.new(
          load_response('notifications/contact-deleted'))
    end
    subject { @notification }

    should 'have contact id' do
      assert_equal 'EPPID0003', subject.id
    end
    should 'have roid' do
      assert_equal '1002703-UK', subject.roid
    end
  end
end
