require 'helper'

class TestNominetRegistrarChangeNotification < Test::Unit::TestCase
  context 'NominetEPP::Notifications::RegistrarChange' do
    setup do
      @notification =
        NominetEPP::Notification.new(
          load_response('notifications/registrar-change'))
    end
    subject { @notification }

    should 'have originator' do
      assert_equal 'p@automaton-example.org.uk', subject.originator
    end
    should 'have registrar tag' do
      assert_equal 'EXAMPLE', subject.registrar_tag
    end
    context '#domains' do
      subject { @notification.domains }
      context '[0]' do
        subject { @notification.domains[0] }
        should 'have name' do
          assert_equal 'auto-example1.co.uk', subject.name
        end
        should 'have roid' do
          assert_equal '65876854-UK', subject.roid
        end
        should 'have nameservers' do
          expected = %w(ns0.epp-example.co.uk ns1.epp-example.co.uk)
          assert_equal expected, subject.nameservers
        end
        should 'have client id' do
          assert_equal 'EXAMPLE-TAG', subject.client_id
        end
        should 'have creator id' do
          assert_equal 'example@epp-exam', subject.creator_id
        end
        should 'have created date' do
          expected = Time.mktime(2005,6,3,12)
          assert_equal expected, subject.created_date
        end
        should 'have expiration date' do
          expected = Time.mktime(2007,6,3,12)
          assert_equal expected, subject.expiration_date
        end
      end
      context '[1]' do
        subject { @notification.domains[1] }
        should 'have name' do
          assert_equal 'epp-example2.co.uk', subject.name
        end
        should 'have roid' do
          assert_equal '568957896-UK', subject.roid
        end
        should 'have client id' do
          assert_equal 'EXAMPLE-TAG', subject.client_id
        end
        should 'have creator id' do
          assert_equal 'example@epp-exa', subject.creator_id
        end
        should 'have created date' do
          expected = Time.mktime(2005,6,3,12)
          assert_equal expected, subject.created_date
        end
        should 'have expiration date' do
          expected = Time.mktime(2007,6,3,12)
          assert_equal expected, subject.expiration_date
        end
      end
    end
    context '#contact' do
      subject { @notification.contact }
      should 'have contact id' do
        assert_equal 'ST96503FG', subject.id
      end
      should 'have contact roid' do
        assert_equal '5876578-UK', subject.roid
      end
      should 'have contact postal info' do
        expected = { :name => "Mr R Strant",
          :org => "reg company",
          :addr => {
            :street => "2102 High Street",
            :city => "Oxford",
            :sp => "Oxon",
            :pc => "OX1 1QQ",
            :cc => "GB" }}
        assert_equal expected, subject.postal_info
      end
      should 'have contact voice' do
        assert_equal '+44.1865123456', subject.voice
      end
      should 'have contact email' do
        assert_equal 'r.strant@epp-example.co.uk', subject.email
      end
      should 'have contact client id' do
        assert_equal 'TEST', subject.client_id
      end
      should 'have contact creator id' do
        assert_equal 'domains@epp-exam', subject.creator_id
      end
      should 'have contact created date' do
        expected = Time.gm(1999,4,3,22,0,0)
        assert_equal expected, subject.created_date
      end
      should 'have contact updator id' do
        assert_equal 'domains@isp.com', subject.updator_id
      end
      should 'have contact updated date' do
        expected = Time.gm(1999,12,3,9,0,0)
        assert_equal expected, subject.updated_date
      end
    end
  end
end
