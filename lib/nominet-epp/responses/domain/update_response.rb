module NominetEPP
  module Domain
    class UpdateResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Domain::UpdateResponse.new(response)
      end
    end
  end
end
