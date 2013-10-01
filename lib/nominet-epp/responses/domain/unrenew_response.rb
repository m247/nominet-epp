module NominetEPP
  module Domain
    class UnrenewResponse < BasicResponse
      def initialize(response)
        raise ArgumentError, "must be an EPP::Response" unless response.kind_of?(EPP::Response)
        super
      end

      def expires?(name)
        expired[name]
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
