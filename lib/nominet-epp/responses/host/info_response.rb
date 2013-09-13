module NominetEPP
  module Host
    class InfoResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        @response = EPP::Host::InfoResponse.new(response)
      end

      def name
        @name ||= @response.name.sub(/\.$/, '')
      end

      def method_missing(method, *args, &block)
        return super unless @response.respond_to?(method)
        @response.send(method, *args, &block)
      end

      def respond_to_missing?(method, include_private)
        @response.respond_to?(method, include_private)
      end
    end
  end
end
