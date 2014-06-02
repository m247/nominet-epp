module NominetEPP
  module Contact
    class CreateResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Contact::CreateResponse.new(response)
      end

      def name
        @response.id
      end
    end
  end
end
