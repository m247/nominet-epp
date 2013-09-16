module NominetEPP
  module Custom
    class ListResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        @response = response
      end

      def domains
        @domains ||= parse_listData
      end

      def namespaces
        { 'list' => 'http://www.nominet.org.uk/epp/xml/std-list-1.0' }
      end

      def method_missing(method, *args, &block)
        return super unless @response.respond_to?(method)
        @response.send(method, *args, &block)
      end

      def respond_to_missing?(method, include_private)
        @response.respond_to?(method, include_private)
      end

      protected
        def parse_listData
          domains = []
          
          @response.data.find('//list:domainName', namespaces).each do |node|
            domains << node.content.strip
          end
          
          domains
        end
    end
  end
end
