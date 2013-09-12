require 'helper'

class TestNominetUpdateRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Update' do
    context 'no extensions' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Domain::Update.new('example.co.uk',
          :add => {:ns => %w(ns1.test.host ns2.test.host)},
          :rem => {:ns => %w(ns3.test.host ns4.test.host)},
          :chg => {:registrant => 'UK-2349723'})
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have update element' do
        assert xpath_exists?('//domain:update'), "should have update element"
      end

      should 'have name element' do
        assert_equal 'example.co.uk', xpath_find('//domain:name')
      end

      should 'not have extension element' do
        assert !xpath_exists?('//epp:extension'), "should not have extension element"
      end
    end
    context 'nominet extensions' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Domain::Update.new('example.co.uk',
          :add => {:renew_not_required => true},
          :chg => {:first_bill => 'th', :auto_bill => 1})
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have update element' do
        assert xpath_exists?('//domain:update'), "should have update element"
      end

      should 'have name element' do
        assert_equal 'example.co.uk', xpath_find('//domain:name')
      end

      should 'have domain extension element' do
        assert xpath_exists?('//domain-ext:update'), "should have extension update element"
      end
      should 'have changed first-bill element' do
        assert_equal 'th', xpath_find('//domain-ext:first-bill')
      end
      should 'have changed auto-bill element' do
        assert_equal '1', xpath_find('//domain-ext:auto-bill')
      end
      should 'have added renew-not-required element' do
        assert_equal 'Y', xpath_find('//domain-ext:renew-not-required')
      end

      should 'not have secDNS extension' do
        assert !xpath_exists?('//update[namespace-uri()="urn:ietf:params:xml:ns:secDNS-1.1"]'),
          "should not have secDNS extension"
      end
    end
    context 'dnssec extensions' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Domain::Update.new('example.co.uk',
          :add => {:ds => [{
            :key_tag => 37102, :alg => 5, :digest_type => 1,
              :digest => "C9E29CA7712DCAD2D93B49774F7EFF30E54E9EC5" }]},
          :rem => {:ds => [{
            :key_tag => 37105, :alg => 5, :digest_type => 1,
              :digest => "C9E29CA7712DCAD2D93B49774F7EFF30E54E9EC57E57" }]})
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have DNSSEC extension element' do
        assert xpath_exists?('//secDNS:update'), "should have DNSSEC extension element"
      end
      should 'have add keyTag' do
        assert_equal '37102', xpath_find('//secDNS:add/secDNS:dsData/secDNS:keyTag')
      end
      should 'have add alg' do
        assert_equal '5', xpath_find('//secDNS:add/secDNS:dsData/secDNS:alg')
      end
      should 'have add digestType' do
        assert_equal '1', xpath_find('//secDNS:add/secDNS:dsData/secDNS:digestType')
      end
      should 'have add digest' do
        expected = "C9E29CA7712DCAD2D93B49774F7EFF30E54E9EC5"
        assert_equal expected, xpath_find('//secDNS:add/secDNS:dsData/secDNS:digest')
      end
      should 'have rem keyTag' do
        assert_equal '37105', xpath_find('//secDNS:rem/secDNS:dsData/secDNS:keyTag')
      end
      should 'have rem alg' do
        assert_equal '5', xpath_find('//secDNS:rem/secDNS:dsData/secDNS:alg')
      end
      should 'have rem digestType' do
        assert_equal '1', xpath_find('//secDNS:rem/secDNS:dsData/secDNS:digestType')
      end
      should 'have rem digest' do
        expected = "C9E29CA7712DCAD2D93B49774F7EFF30E54E9EC57E57"
        assert_equal expected, xpath_find('//secDNS:rem/secDNS:dsData/secDNS:digest')
      end

      should 'not have domain-ext extension' do
        assert !xpath_exists?('//create[namespace-uri()="http://www.nominet.org.uk/epp/xml/domain-nom-ext-1.2"]'), "should not have domain-ext extension"
      end
    end
    context 'all extensions' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Domain::Update.new('example.co.uk',
          :add => {
            :renew_not_required => true,
            :ns => %w(ns1.test.host ns2.test.host),
            :ds => [{
              :key_tag => 37102, :alg => 5, :digest_type => 1,
                :digest => "C9E29CA7712DCAD2D93B49774F7EFF30E54E9EC5" }]},
          :chg => {
            :registrant => 'UK-2349723',
            :first_bill => 'th', :auto_bill => 1},
          :rem => {
            :ns => %w(ns3.test.host ns4.test.host),
            :ds => [{
              :key_tag => 37105, :alg => 5, :digest_type => 1,
                :digest => "C9E29CA7712DCAD2D93B49774F7EFF30E54E9EC57E57" }]})
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have domain extension element' do
        assert xpath_exists?('//domain-ext:update'), "should have extension update   element"
      end

      should 'have DNSSEC extension element' do
        assert xpath_exists?('//secDNS:update'), "should have DNSSEC extension element"
      end
    end
  end
end
