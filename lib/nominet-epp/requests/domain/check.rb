module NominetEPP
  module Domain
    class Check < Request
      def initialize(*names)
        @command = EPP::Domain::Check.new(*names)
      end
    end
  end
end
