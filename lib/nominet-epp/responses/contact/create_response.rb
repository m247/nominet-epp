module NominetEPP
  module Contact
    class CreateResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        @response = EPP::Contact::CreateResponse.new(response)
      end

      undef :to_s

      def name
        @response.id
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
