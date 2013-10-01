module NominetEPP
  module Contact
    class ReleaseResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super
      end
    end
  end
end
