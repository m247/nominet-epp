require 'helper'

class TestNominetDomainsReleasedNotification < Test::Unit::TestCase
  context 'NominetEPP::Notifications::DomainsReleased' do
    setup do
      @notification =
        NominetEPP::Notification.new(
          load_response('notifications/domains-released'))
    end
    subject { @notification }

    should 'have account ID' do
      assert_equal '12345', subject.account_id
    end
    should 'flag account ID as moved' do
      assert_equal true, subject.account_moved?
    end
    should 'have EXAMPLE1-TAG as sender' do
      assert_equal 'EXAMPLE1-TAG', subject.from
    end
    should 'have EXAMPLE2-TAG as receiver' do
      assert_equal 'EXAMPLE2-TAG', subject.registrar_tag
    end
    should 'have domains' do
      expected = %w(epp-example1.co.uk epp-example2.co.uk epp-example3.co.uk
        epp-example4.co.uk epp-example5.co.uk epp-example6.co.uk)
      assert_equal expected, subject.domains
    end
  end
end
