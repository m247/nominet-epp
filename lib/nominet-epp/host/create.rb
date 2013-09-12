module NominetEPP
  module Host
    class Create < Request
      def initialize(name, attributes = {})
        @command = EPP::Host::Create.new(name, attributes)
      end
    end
  end
end
