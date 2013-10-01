module NominetEPP
  module Host
    class CreateResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Host::CreateResponse.new(response)
      end

      def name
        @name ||= @response.name.sub(/\.$/, '')
      end
    end
  end
end
