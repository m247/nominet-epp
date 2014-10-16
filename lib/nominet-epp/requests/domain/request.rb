module NominetEPP
  module Domain
    class Request < ::NominetEPP::Request
      def validate_period(period)
        unit = period[-1,1]
        val  = period.to_i
        
        if unit == 'y' && val > 10
          raise ArgumentError, "maximum period accepted by Nominet is 10 years"
        end
      end
    end
  end
end
