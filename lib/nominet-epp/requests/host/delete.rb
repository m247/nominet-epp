module NominetEPP
  module Host
    class Delete < Request
      def initialize(name)
        @command = EPP::Host::Delete.new(name)
      end
    end
  end
end
