module NominetEPP
  module Operations
    # EPP Poll Operation
    module Poll
      # Poll the EPP server for events
      #
      # @yield [data] process data if messages to poll
      # @yieldparam [XML::Node] data Response data
      # @return [nil] no messages to handle
      # @return [Boolean] ack successful
      # @see ack
      def poll
        resp = @client.poll do |poll|
          poll['op'] = 'req'
        end

        return if resp.code != 1301 || resp.msgQ['count'] == '0'

        yield resp.data

        ack(resp.msgQ['id'])
      end

      # Acknowledges a polled message ID
      #
      # @param [String] msgID Message ID to acknowledge
      # @return [Boolean] ack successful
      def ack(msgID)
        resp = @client.poll do |poll|
          poll['op'] = 'ack'
          poll['msgID'] = msgID
        end

        return resp.success?
      end
    end
  end
end
