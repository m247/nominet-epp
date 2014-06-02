module NominetEPP
  module Contact
    class CheckResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Contact::CheckResponse.new(response)
      end
    end
  end
end
