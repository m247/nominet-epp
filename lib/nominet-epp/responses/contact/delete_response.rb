module NominetEPP
  module Contact
    class DeleteResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Contact::DeleteResponse.new(response)
      end
    end
  end
end
