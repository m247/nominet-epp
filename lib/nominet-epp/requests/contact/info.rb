module NominetEPP
  module Contact
    class Info < Request
      def initialize(id)
        @command = EPP::Contact::Info.new(id)
      end
    end
  end
end
