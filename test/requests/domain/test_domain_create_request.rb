require 'helper'

class TestNominetDomainCreateRequest < Test::Unit::TestCase
  context 'NominetEPP::Domain::Create' do
    context 'no extensions' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Domain::Create.new('example.co.uk',
          :period => '2y', :registrant => 'UK-2349723',
          :nameservers => %w(ns1.test.host ns2.test.host),
          :auth_info => {:pw => '2381728348'})
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have create element' do
        assert xpath_exists?('//domain:create'), "should have create element"
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
        @request = NominetEPP::Domain::Create.new('example.co.uk',
          :period => '2y', :registrant => 'UK-2349723',
          :nameservers => %w(ns1.test.host ns2.test.host),
          :auth_info => {:pw => '2381728348'},
          :first_bill => 'th', :recur_bill => 'th', :auto_bill => 1)
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have domain extension element' do
        assert xpath_exists?('//domain-ext:create'), "should have extension create element"
      end
      should 'have first-bill element' do
        assert_equal 'th', xpath_find('//domain-ext:first-bill')
      end
      should 'have recur-bill element' do
        assert_equal 'th', xpath_find('//domain-ext:recur-bill')
      end
      should 'have auto-bill element' do
        assert_equal '1', xpath_find('//domain-ext:auto-bill')
      end

      should 'not have secDNS extension' do
        assert !xpath_exists?('//create[namespace-uri()="urn:ietf:params:xml:ns:secDNS-1.1"]'), "should not have secDNS extension"
      end
    end
    context 'dnssec extensions' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Domain::Create.new('example.co.uk',
          :period => '2y', :registrant => 'UK-2349723',
          :nameservers => %w(ns1.test.host ns2.test.host),
          :auth_info => {:pw => '2381728348'},
          :ds => [{
            :key_tag => 37102, :alg => 5, :digest_type => 1,
              :digest => "C9E29CA7712DCAD2D93B49774F7EFF30E54E9EC5" }])
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have DNSSEC extension element' do
        assert xpath_exists?('//secDNS:create'), "should have DNSSEC extension element"
      end
      should 'have keyTag' do
        assert_equal '37102', xpath_find('//secDNS:keyTag')
      end
      should 'have alg' do
        assert_equal '5', xpath_find('//secDNS:alg')
      end
      should 'have digestType' do
        assert_equal '1', xpath_find('//secDNS:digestType')
      end
      should 'have digest' do
        expected = "C9E29CA7712DCAD2D93B49774F7EFF30E54E9EC5"
        assert_equal expected, xpath_find('//secDNS:digest')
      end
      
      should 'not have domain-ext extension' do
        assert !xpath_exists?('//create[namespace-uri()="http://www.nominet.org.uk/epp/xml/domain-nom-ext-1.2"]'), "should not have domain-ext extension"
      end
    end
    context 'all extensions' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Domain::Create.new('example.co.uk',
          :period => '2y', :registrant => 'UK-2349723',
          :nameservers => %w(ns1.test.host ns2.test.host),
          :auth_info => {:pw => '2381728348'},
          :first_bill => 'th', :recur_bill => 'th', :auto_bill => 1,
          :ds => [{
            :key_tag => 37102, :alg => 5, :digest_type => 1,
              :digest => "C9E29CA7712DCAD2D93B49774F7EFF30E54E9EC5" }])
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have domain extension element' do
        assert xpath_exists?('//domain-ext:create'), "should have extension create element"
      end

      should 'have DNSSEC extension element' do
        assert xpath_exists?('//secDNS:create'), "should have DNSSEC extension element"
      end
    end
    context '10 year registration' do
      context 'period = 10y' do
        setup do
          @time    = Time.now.utc
          @request = NominetEPP::Domain::Create.new('example.co.uk',
            :period => '10y', :registrant => 'UK-2349723',
            :nameservers => %w(ns1.test.host ns2.test.host),
            :auth_info => {:pw => '2381728348'})
          @xml     = prepare_request.to_xml

          namespaces_from_request
        end

        should 'validate against schema' do
          assert @xml.validate_schema(schema)
        end

        should 'have create element' do
          assert xpath_exists?('//domain:create'), "should have create element"
        end

        should 'have name element' do
          assert_equal 'example.co.uk', xpath_find('//domain:name')
        end
        
        should 'have period elemement of 10y' do
          assert_equal '10', xpath_find('//domain:period')
          assert_equal 'y', xpath_find('//domain:period/@unit')
        end

        should 'not have extension element' do
          assert !xpath_exists?('//epp:extension'), "should not have extension element"
        end
      end
      context 'period = 120m' do
        setup do
          @time    = Time.now.utc
          @request = NominetEPP::Domain::Create.new('example.co.uk',
            :period => '120m', :registrant => 'UK-2349723',
            :nameservers => %w(ns1.test.host ns2.test.host),
            :auth_info => {:pw => '2381728348'})
          @xml     = prepare_request.to_xml

          namespaces_from_request
        end

        should 'validate against schema' do
          assert @xml.validate_schema(schema)
        end

        should 'have create element' do
          assert xpath_exists?('//domain:create'), "should have create element"
        end

        should 'have name element' do
          assert_equal 'example.co.uk', xpath_find('//domain:name')
        end
        
        should 'have period elemement of 10y' do
          assert_equal '10', xpath_find('//domain:period')
          assert_equal 'y', xpath_find('//domain:period/@unit')
        end

        should 'not have extension element' do
          assert !xpath_exists?('//epp:extension'), "should not have extension element"
        end
      end
    end
  end
end
