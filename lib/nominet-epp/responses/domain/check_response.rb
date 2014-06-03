module NominetEPP
  module Domain
    class CheckResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Domain::CheckResponse.new(response)

        ext_chk_data
      end

      def namespaces
        { 'domain-ext' => 'http://www.nominet.org.uk/epp/xml/domain-nom-ext-1.2',
          'nom-direct-rights' => 'http://www.nominet.org.uk/epp/xml/nom-direct-rights-1.0' }
      end

      def abuse_limit
        @abuse_limit
      end

      def right_of_registration
        @right_of_registration
      end

      protected
        def ext_chk_data
          [@response.extension].flatten.compact.each do |node|
            next unless node.name == 'chkData'

            node.find('//domain-ext:chkData', namespaces).each do |chkData|
              @abuse_limit = chkData['abuse-limit'].to_i
            end

            node.find('//nom-direct-rights:chkData', namespaces).each do |chkData|
              @right_of_registration = chkData.find('nom-direct-rights:ror').first.content.strip
              @right_of_registration = nil if @right_of_registration == ""
            end
          end
        end
    end
  end
end
