module NominetEPP
  module Domain
    class CreateResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Domain::CreateResponse.new(response)
      end
    end
  end
end
