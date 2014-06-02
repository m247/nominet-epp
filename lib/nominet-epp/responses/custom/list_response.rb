module NominetEPP
  module Custom
    class ListResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super
      end

      def domains
        @domains ||= parse_listData
      end

      def namespaces
        { 'list' => 'http://www.nominet.org.uk/epp/xml/std-list-1.0' }
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
