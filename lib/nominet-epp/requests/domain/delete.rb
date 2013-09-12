module NominetEPP
  module Domain
    class Delete < Request
      def initialize(name)
        @command = EPP::Domain::Delete.new(name)
      end
    end
  end
end
