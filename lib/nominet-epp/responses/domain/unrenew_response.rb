module NominetEPP
  module Domain
    class UnrenewResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        @response = response
      end

      undef :to_s

      def expires?(name)
        expired[name]
      end

      def method_missing(method, *args, &block)
        return super unless @response.respond_to?(method)
        @response.send(method, *args, &block)
      end

      def respond_to_missing?(method, include_private)
        @response.respond_to?(method, include_private)
      end

      protected
        def expired
          @expired ||= Array(@response.data).inject({}) do |hash, renData|
            name   = renData.find('domain:name').first.content.strip
            exDate = renData.find('domain:exDate').first.content.strip
            exDate = Time.parse(exDate)

            hash[name] = exDate
            hash
          end
        end
    end
  end
end
