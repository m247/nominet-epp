module NominetEPP
  module Operations
    module Poll
      def poll
        resp = @client.poll do |poll|
          poll['op'] = 'req'
        end

        return if resp.code != 1301 || resp.msgQ['count'] == '0'

        yield resp.data

        ack(resp.msgQ['id'])
      end
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
