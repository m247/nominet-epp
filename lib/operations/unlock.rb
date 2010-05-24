module NominetEPP
  module Operations
    module Unlock
      def unlock(entity, type, id)
        raise ArgumentError, "entity must be :domain or :account" unless [:domain, :account].include?(entity)
        raise ArgumentError, "type must be 'investigation' or 'opt-out'" unless %w(investigation opt-out).include?(type)

        resp = @client.update do
          case type
          when 'investigation'
            lock_investigation(entity, id)
          when 'opt-out'
            lock_opt_out(entity, id)
          end
        end

        return resp.success?
      end
      private
        def unlock_opt_out(entity, id)
          account('unlock') do |node, ns|
            node['type'] = 'opt-out'
            node << XML::Node.new((entity == :domain ? 'domain-name' : 'roid'), id, ns)
          end
        end
        # We don't support 'investigation' on account:domain-name as this ability
        # is already provided via domain:name
        def unlock_investigation(entity, id)
          self.send(entity, 'unlock') do |node, ns|
            node['type'] = 'investigation'
            node << XML::Node.new((entity == :domain ? 'name' : 'roid'), id, ns)
          end
        end
    end
  end
end
