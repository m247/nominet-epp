module NominetEPP
  module Contact
    class UpdateResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Contact::UpdateResponse.new(response)
      end
    end
  end
end
