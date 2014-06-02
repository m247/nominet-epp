module NominetEPP
  module Host
    class UpdateResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Host::UpdateResponse.new(response)
      end
    end
  end
end
