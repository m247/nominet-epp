module NominetEPP
  module Domain
    class Info < Request
      def initialize(name)
        @command = EPP::Domain::Info.new(name)
      end
    end
  end
end
