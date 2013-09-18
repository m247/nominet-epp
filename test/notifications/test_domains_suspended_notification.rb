require 'helper'

class TestNominetDomainsSuspendedNotification < Test::Unit::TestCase
  context 'NominetEPP::Notifications::DomainsSuspended' do
    setup do
      @notification =
        NominetEPP::Notification.new(
          load_response('notifications/domains-suspended'))
    end
    subject { @notification }

    should 'have type' do
      assert_equal :domains_suspended, subject.type
    end

    should 'have reason' do
      assert_equal 'Data Quality', subject.reason
    end

    should 'have cancellation date' do
      expected = Time.gm(2009,12,12,0,0,13)
      assert_equal expected, subject.cancellation_date
    end

    should 'have domains' do
      expected = %w(epp-example1.co.uk epp-example2.co.uk)
      assert_equal expected, subject.domains
    end
  end
end
