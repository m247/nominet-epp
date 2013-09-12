module NominetEPP
  module Host
    class Info < Request
      def initialize(name)
        @command = EPP::Host::Info.new(name)
      end
    end
  end
end
