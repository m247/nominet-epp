module NominetEPP
  module Operations
    # EPP Hello Operation
    module Hello
      # @return [Boolean] hello greeting returned
      def hello
        @client.hello  # This should be a epp-client method
      end
    end
  end
end
