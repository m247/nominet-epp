module NominetEPP
  module Custom
    class HandshakeResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        @response = response
      end

      undef to_s

      def case_id
        @case_id ||= @response.data.find('//h:caseId', namespaces).first.content.strip
      end
      
      def domains
        @domains ||= parse_domainList
      end

      def namespaces
        { 'h' => 'http://www.nominet.org.uk/epp/xml/std-handshake-1.0' }
      end

      def method_missing(method, *args, &block)
        return super unless @response.respond_to?(method)
        @response.send(method, *args, &block)
      end

      def respond_to_missing?(method, include_private)
        @response.respond_to?(method, include_private)
      end

      protected
        def parse_domainList
          domains = []
          
          @response.data.find('//h:domainName', namespaces).each do |node|
            domains << node.content.strip
          end
          
          domains
        end
    end
  end
end
