module NominetEPP
  module Contact
    class Check < Request
      def initialize(*ids)
        @command = EPP::Contact::Check.new(*ids)
      end
    end
  end
end
