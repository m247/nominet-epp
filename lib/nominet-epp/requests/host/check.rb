module NominetEPP
  module Host
    class Check < Request
      def initialize(*names)
        @command = EPP::Host::Check.new(*names)
      end
    end
  end
end
