module NominetEPP
  module Operations
    # EPP Poll Operation
    module Poll
      # Error for indicating a failed poll ack response
      class AckError < RuntimeError; end

      # Poll the EPP server for events.
      #
      # If a block is given then it will be invoked once for
      # each pending event. If no block is given the only the
      # first received event will be returned along with the
      # message ID of the event to allow the message to be
      # ack'd. nil is returned if there is an error in the
      # response or if there are not further messages to process.
      #
      # @example Without a block
      #   msgID, xml = client.poll
      #   ... process xml ...
      #   client.ack(msgID)
      #
      # @example With a block
      #   client.poll do |xml|
      #     ... process xml ...
      #   end
      #
      # @yield [data] process data if messages to poll
      # @yieldparam [XML::Node] data Response data
      # @return [nil] no messages to handle
      # @return [Array<String,XML::Node>] message ID and response xml data
      # @raise [AckError] ack of event notification failed
      # @see ack
      def poll
        while resp = poll_req
          return if resp.code != 1301 || resp.msgQ['count'] == '0'
          return [resp.msgQ['id'], resp.data] unless block_given?

          yield resp.data
          raise AckError, "failed to acknowledge message #{resp.msgQ['id']}" unless ack(resp.msgQ['id'])
        end
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

      protected
        def poll_req
          @client.poll do |poll|
            poll['op'] = 'req'
          end
        end
    end
  end
end
