module NominetEPP
  module Operations
    # EPP Release Operation
    module Release
      # @note Releasing a contact or registrant will release all of their
      #   domain names as well.
      def release(entity, id, tag)
        raise ArgumentError, "entity must be :domain or :contact/:registrant" unless [:domain, :contact, :registrant].include?(entity)

        resp = @client.update do
          release('release') do |node, ns|
            case entity
            when :domain
              node << XML::Node.new('domainName', id, ns)
            when :contact, :registrant
              node << XML::Node.new('registrant', id, ns)
            end

            node << XML::Node.new('registrarTag', tag, ns)
          end
        end

        case resp.code
        when 1000
          { :result => true }
        when 1001
          { :result => :handshake }
        else
          false
        end
      end
    end
  end
end
