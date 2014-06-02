module NominetEPP
  class BasicResponse
    def initialize(response)
      @response = response
    end

    undef to_s

    def method_missing(method, *args, &block)
      return super unless @response.respond_to?(method)
      @response.send(method, *args, &block)
    end

    def respond_to_missing?(method, include_private)
      @response.respond_to?(method, include_private)
    end

    unless RUBY_VERSION >= "1.9.2"
      def respond_to?(method, include_private = false)
        respond_to_missing?(method, include_private) || super
      end
      def method(sym)
        respond_to_missing?(sym, true) ? @response.method(sym) : super
      end
    end
  end
end
