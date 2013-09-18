require 'helper'

class TestNominetDomainCancelledNotification < Test::Unit::TestCase
  context 'NominetEPP::Notifications::DomainCancelled' do
    setup do
      @notification =
        NominetEPP::Notification.new(
          load_response('notifications/domain-cancelled'))
    end
    subject { @notification }

    should 'have type' do
      assert_equal :domain_cancelled, subject.type
    end

    should 'have domain name' do
      assert_equal 'epp-example1.co.uk', subject.name
    end
    should 'have originator' do
      assert_equal 'example@nominet', subject.originator
    end
  end
end
