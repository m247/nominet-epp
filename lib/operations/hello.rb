module NominetEPP
  module Operations
    module Hello
      def hello
        @client.hello  # This should be a epp-client method
      end
    end
  end
end
