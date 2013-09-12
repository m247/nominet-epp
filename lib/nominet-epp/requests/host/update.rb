module NominetEPP
  module Host
    class Update < Request
      def initialize(name, attributes = {})
        @command = EPP::Host::Update.new(name, attributes)
      end
    end
  end
end
