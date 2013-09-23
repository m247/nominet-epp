require 'helper'

class TestNominetRegistrantTransferNotification < Test::Unit::TestCase
  context 'NominetEPP::Notifications::RegistrantTransfer' do
    setup do
      @notification =
        NominetEPP::Notification.new(
          load_response('notifications/registrant-transfer'))
    end
    subject { @notification }

    should 'have type' do
      assert_equal :registrant_transfer, subject.type
    end

    should 'have originator' do
      assert_equal 'p@automaton-example.org.uk', subject.originator
    end
    should 'have account Id' do
      assert_equal '58658458', subject.account_id
    end
    should 'have old account Id' do
      assert_equal '596859', subject.old_account_id
    end
    should 'have domains' do
      expected = %w(epp-example1.co.uk epp-example2.co.uk)
      assert_equal expected, subject.domains
    end
    should 'have contact id' do
      assert_equal 'ST68956589R4', subject.contact.id
    end
    should 'have contact roid' do
      assert_equal '123456-UK', subject.contact.roid
    end
    should 'have contact postal info' do
      expected = { :name => "Mr R. Strant",
        :addr => {
          :street => "2102 High Street",
          :city => "Oxford",
          :sp => "Oxon",
          :pc => "OX1 1QQ",
          :cc => "GB" }}
      assert_equal expected, subject.contact.postal_info
    end
    should 'have contact email' do
      assert_equal 'example@epp-example1.co.uk', subject.contact.email
    end
    should 'have nil voice' do
      assert_equal nil, subject.contact.voice
    end
    should 'have nil fax' do
      assert_equal nil, subject.contact.fax
    end
    should 'have contact client id' do
      assert_equal 'TEST', subject.contact.client_id
    end
    should 'have contact creator id' do
      assert_equal 'TEST', subject.contact.creator_id
    end
    should 'have contact created date' do
      expected = Time.gm(1999,4,3,22,0,0)
      assert_equal expected, subject.contact.created_date
    end
    should 'have contact updator id' do
      assert_equal 'domains@isp.com', subject.contact.updator_id
    end
    should 'have contact updated date' do
      expected = Time.gm(1999,12,3,9,0,0)
      assert_equal expected, subject.contact.updated_date
    end
  end
end
