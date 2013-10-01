module NominetEPP
  module Domain
    class CheckResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super EPP::Domain::CheckResponse.new(response)
      end

      def abuse_limit
        @response.extension.find('//domain-nom-ext:chkData/@abuse-limit').first.value.to_i
      end
    end
  end
end
