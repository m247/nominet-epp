module NominetEPP
  module Host
    class CheckResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Host::CheckResponse.new(response)
      end
    end
  end
end
