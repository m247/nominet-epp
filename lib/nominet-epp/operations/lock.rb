module NominetEPP
  module Operations
    # EPP Lock Operation
    module Lock
      # Lock domain or account 'investigation' or 'opt-out'
      #
      # @param [Symbol] entity Entity to lock
      # @param [String] type Type of lock to set
      # @param [String] id Domain name or account ID
      # @raise [ArgumentError] entity is not +:domain+ or +:account+
      # @raise [ArgumentError] type is not 'investigation' or 'opt-out'
      # @return [Boolean] locking successful
      def lock(entity, type, id)
        raise ArgumentError, "entity must be :domain or :account" unless [:domain, :account].include?(entity)
        raise ArgumentError, "type must be 'investigation' or 'opt-out'" unless %w(investigation opt-out).include?(type)

        @resp = @client.update do
          case type
          when 'investigation'
            lock_investigation(entity, id)
          when 'opt-out'
            lock_opt_out(entity, id)
          end
        end

        return @resp.success?
      end
      private
        # Create +account:lock+ XML element for opt-out lock
        # @param [Symbol] entity Entity to set opt out lock on
        # @param [String] id Domain name or Account ID to lock
        # @return [XML::Node] +account:lock+ element
        def lock_opt_out(entity, id)
          account('lock') do |node, ns|
            node['type'] = 'opt-out'
            node << XML::Node.new((entity == :domain ? 'domain-name' : 'roid'), id, ns)
          end
        end

        # Create +lock+ XML element for investigation lock
        #
        # We don't support 'investigation' on account:domain-name as this ability
        # is already provided via domain:name
        #
        # @param [Symbol] entity Entity to set investigation lock on
        # @param [String] id Domain name or account ID to set lock on
        # @return [XML::Node] +lock+ element
        def lock_investigation(entity, id)
          self.send(entity, 'lock') do |node, ns|
            node['type'] = 'investigation'
            node << XML::Node.new((entity == :domain ? 'name' : 'roid'), id, ns)
          end
        end
    end
  end
end
