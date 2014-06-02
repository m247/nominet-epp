module NominetEPP
  module Domain
    class RenewResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Domain::RenewResponse.new(response)
      end
    end
  end
end
