module NominetEPP
  module Operations
    # EPP Hello Operation
    module Hello
      # @return [Boolean] hello greeting returned
      def hello
        instrument :hello do
          @client.hello
        end
      end
    end
  end
end
