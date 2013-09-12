require 'helper'

class TestNominetContactUpdateRequest < Test::Unit::TestCase
  context 'NominetEPP::Contact::Update' do
    context 'no extensions' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Contact::Update.new('sh8013',
          :chg => {
            :voice       => "+44.1234567890",
            :email       => "enoch.root@test.host",
            :postal_info => {
              :org       => "Epiphyte",
              :name      => "Enoch Root",
              :addr      => {
                :street  => "1 Test Avenue",
                :city    => "Testington",
                :sp      => "Testshire",
                :pc      => "TE57 1NG",
                :cc      => "GB" }}})
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have update element' do
        assert xpath_exists?('//contact:update'), "should have update element"
      end

      should 'have name element' do
        assert_equal 'sh8013', xpath_find('//contact:id')
      end

      should 'set voice for change' do
        assert_equal "+44.1234567890", xpath_find('//contact:chg/contact:voice')
      end
      should 'set email for change' do
        assert_equal "enoch.root@test.host", xpath_find('//contact:chg/contact:email')
      end
      should 'set organisation for change' do
        assert_equal "Epiphyte", xpath_find('//contact:chg/contact:postalInfo[@type="loc"]/contact:org')
      end
      should 'set name for change' do
        assert_equal "Enoch Root", xpath_find('//contact:chg/contact:postalInfo[@type="loc"]/contact:name')
      end
      should 'set address for change' do
        assert_equal "1 Test Avenue", xpath_find('//contact:chg/contact:postalInfo[@type="loc"]/contact:addr/contact:street')
        assert_equal "Testington", xpath_find('//contact:chg/contact:postalInfo[@type="loc"]/contact:addr/contact:city')
        assert_equal "Testshire", xpath_find('//contact:chg/contact:postalInfo[@type="loc"]/contact:addr/contact:sp')
        assert_equal "TE57 1NG", xpath_find('//contact:chg/contact:postalInfo[@type="loc"]/contact:addr/contact:pc')
        assert_equal "GB", xpath_find('//contact:chg/contact:postalInfo[@type="loc"]/contact:addr/contact:cc')
      end

      should 'not have extension element' do
        assert !xpath_exists?('//epp:extension'), "should not have extension element"
      end
    end
    context 'nominet extensions' do
      setup do
        @time    = Time.now.utc
        @request = NominetEPP::Contact::Update.new('sh8013',
          :add => {
            :trad_name   => "Trading name",
            :type        => "LTD",
            :co_no       => "12345678" },
          :chg => {
            :opt_out     => false})
        @xml     = prepare_request.to_xml

        namespaces_from_request
      end

      should 'validate against schema' do
        assert @xml.validate_schema(schema)
      end

      should 'have update element' do
        assert xpath_exists?('//contact:update'), "should have update element"
      end

      should 'have name element' do
        assert_equal 'sh8013', xpath_find('//contact:id')
      end

      should 'have contact extension element' do
        assert xpath_exists?('//contact-ext:update'), "should have extension update element"
      end

      should 'set trad-name' do
        assert_equal "Trading name", xpath_find('//contact-ext:trad-name')
      end

      should 'set type' do
        assert_equal "LTD", xpath_find('//contact-ext:type')
      end

      should 'set co-no' do
        assert_equal "12345678", xpath_find('//contact-ext:co-no')
      end

      should 'set opt-out' do
        assert_equal "N", xpath_find('//contact-ext:opt-out')
      end
    end
  end
end
