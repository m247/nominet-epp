module NominetEPP
  module Contact
    class Delete < Request
      def initialize(id)
        @command = EPP::Contact::Delete.new(id)
      end
    end
  end
end
