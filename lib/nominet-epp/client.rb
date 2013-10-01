module NominetEPP
  # Front end interface Client to the NominetEPP Service
  class Client
    # Standard EPP Services to be used
    SERVICE_URNS = EPP::Client::DEFAULT_SERVICES

    # Additional Nominet specific service extensions
    SERVICE_EXTENSION_URNS = %w(
      urn:ietf:params:xml:ns:secDNS-1.1
      http://www.nominet.org.uk/epp/xml/domain-nom-ext-1.2
      http://www.nominet.org.uk/epp/xml/contact-nom-ext-1.0
      http://www.nominet.org.uk/epp/xml/std-notifications-1.2
      http://www.nominet.org.uk/epp/xml/std-handshake-1.0
      http://www.nominet.org.uk/epp/xml/std-warning-1.1
      http://www.nominet.org.uk/epp/xml/std-release-1.0
      http://www.nominet.org.uk/epp/xml/std-unrenew-1.0
      http://www.nominet.org.uk/epp/xml/std-list-1.0)

    # Create a new instance of NominetEPP::Client
    #
    # @param [String] tag Nominet TAG
    # @param [String] passwd Nominet TAG EPP Password
    # @param [String] server Nominet EPP Server address (nil forces default)
    # @param [String] address_family 'AF_INET' or 'AF_INET6' or either of the
    #                 appropriate socket constants. Will cause connections to be
    #                 limited to this address family. Default try all addresses.
    def initialize(tag, passwd, server = 'epp.nominet.org.uk', address_family = nil)
      @tag, @server = tag, (server || 'epp.nominet.org.uk')
      @client = EPP::Client.new(@tag, passwd, @server, :services => SERVICE_URNS,
        :extensions => SERVICE_EXTENSION_URNS, :address_family => address_family)
    end

    # @see Object#inspect
    def inspect
      "#<#{self.class} #{@tag}@#{@server}>"
    end

    def self.logger=(l)
      @@logger = l
    end
    def self.logger
      @@logger ||= Logger.new(STDERR).tap do |l|
        l.level = Logger::ERROR
      end
    end
    def logger
      self.class.logger
    end

    # Returns the last EPP::Request sent
    #
    # @return [EPP::Request] last sent request
    def last_request
      @client._last_request
    end

    # Returns the last EPP::Response received
    #
    # @return [EPP::Response] last received response
    def last_response
      @client._last_response
    end

    # Returns the last EPP message received
    #
    # @return [String] last EPP message
    # @see #last_response
    def last_message
      last_response.message
    end

    # Returns the last Nominet failData response found
    #
    # @note This is presently only set by certain method calls,
    #       so it may not always be present.
    # @return [Hash] last failData found
    def last_error_info
      @error_info || {}
    end

    def greeting
      @client._greeting
    end

    def hello
      @client.hello
    end

    def check(entity, *names)
      check_entity! entity

      mod = module_for_type(entity)
      req = mod::Check.new(*names)
      res = @client.check(req.command, req.extension)

      mod::CheckResponse.new(res)
    end

    def create(entity, name, attributes = {})
      check_entity! entity

      mod = module_for_type(entity)
      req = mod::Create.new(name, attributes)
      res = @client.create(req.command, req.extension)

      mod::CreateResponse.new(res)
    end

    def delete(entity, name)
      check_entity! entity

      unless entity == :domain || entity == 'domain'
        raise ArgumentError, "#{entity} entity is not supported for the delete operation at this time"
      end

      mod = module_for_type(entity)
      req = mod::Delete.new(name, attributes)
      res = @client.delete(req.command, req.extension)

      mod::DeleteResponse.new(res)
    end

    def info(entity, name)
      check_entity! entity

      mod = module_for_type(entity)
      req = mod::Info.new(name)
      res = @client.info(req.command, req.extension)

      mod::InfoResponse.new(res)
    end

    def poll
      while res = @client.poll
        res = Notification.new(res)

        return if res.code != 1301 || res.msgQ['count'] == '0'
        return [res.msgQ['id'], res] unless block_given?

        result = yield res
        return if result == false

        raise AckError, "failed to acknowledge #{res.msgQ['id']}" unless @client.ack(res.msgQ['id'])
      end
    end

    def ack(msgID)
      @client.ack(msgID)
    end

    def release(entity, name, tag)
      entity = :contact if entity == 'registrant' || entity == :registrant
      check_entity! entity

      if entity == 'host' || entity == :host
        raise ArgumentError, "host entity is not support for the release operation"
      end

      mod = module_for_type(entity)
      req = mod::Release.new(name, tag)
      res = @client.update(req.command, req.extension)

      mod::ReleaseResponse.new(res)
    end

    def renew(name, expiry_date, period = '2y')
      req = Domain::Renew.new(name, expiry_date, period)
      res = @client.renew(req.command, req.extension)

      Domain::RenewResponse.new(res)
    end

    def update(entity, name, changes = {})
      check_entity! entity

      mod = module_for_type(entity)
      req = mod::Update.new(name, changes)
      res = @client.update(req.command, req.extension)

      mod::UpdateResponse.new(res)
    end

    private
      def check_entity!(entity)
        unless [:domain, :contact, :host, 'domain', 'contact', 'host'].include?(entity)
          raise ArgumentError, "Unsupported entity #{entity}"
        end
      end
      def module_for_type(name)
        case name
        when :domain, 'domain'
          Domain
        when :contact, 'contact'
          Contact
        when :host, 'host'
          Host
        end
      end

      # Wrapper for ActiveSupport::Notifications if available to perform
      # instrumentation of methods.
      #
      # @internal
      # @param [String,Symbol] name Instrument name. Will be prefixed with "request.nominetepp".
      # @param [Hash] payload Extra information to be included with the instrumentation data.
      def instrument(name, payload = {})
        if defined?(ActiveSupport::Notifications)
          ActiveSupport::Notifications.instrument("request.nominetepp.#{name}", payload) do
            yield
          end
        else
          yield
        end
      end

    # OldAPI
    public
      alias_method :new_check, :check
      alias_method :new_create, :create
      alias_method :new_delete, :delete
      alias_method :new_release, :release
      alias_method :new_renew, :renew
      alias_method :new_update, :update
      alias_method :new_info, :info
    
      def check(entity, *names)
        res = new_check(entity, *names)

        if res.respond_to?(:abuse_limit)
          @check_limit = res.abuse_limit
        end

        return res.available?(names.first) if names.length == 1

        names.inject({}) do |hash, name|
          hash[name] = res.available?(name)
          hash
        end
      end
      def create(entity, name, attributes = {})
        res = new_create(entity, name, attributes)

        if res.success?
          case entity
          when :domain, 'domain'
            { :name => res.name,
              :crDate => res.creation_date,
              :exDate => res.expiration_date }
          when :contact, 'contact'
            { :name => res.id,
              :crDate => res.creation_date }
          when :host, 'host'
            { :name => res.id,
              :crDate => res.creation_date }
          end
        else
          @error_info = { :name => res.message, :reason => resp.error_reason }
          return false
        end
      end
      def delete(entity, name)
        res = new_delete(entity, name)
        res.success?
      end
      def release(entity, name, tag)
        res = new_release(entity, name, tag)

        case res.code
        when 1000
          { :result => true }
        when 1001
          { :result => :handshake }
        else
          false
        end
      end
      def renew(name, expiry_date, period = '2y')
        res = new_renew(name, expiry_date, period)

        return false unless res.success?

        raise "Renewed name #{res.name} does not match #{name}" if res.name != name
        return res.expiration_date
      end
      def update(entity, name, changes = {})
        res = new_update(entity, name, changes)
        res.success?
      end
      def info(entity, name)
        res = new_info(entity, name)

        return false unless res.success?
        return self.send(:"old_info_#{entity}", res)
      end
      def old_info_domain(res)
        nameservers = res.nameservers.map do |ns|
          h = { :name => ns['name'] }
          h[:v4] = ns['ipv4'] if ns['ipv4']
          h[:v6] = ns['ipv6'] if ns['ipv6']
          h
        end

        {
          :name => res.name,
          :roid => res.roid,
          :registrant => res.registrant,
          :ns => nameservers,
          :host => res.hosts,
          :clID => res.client_id,
          :crID => res.creator_id,
          :crDate => res.created_date,
          :upDate => res.updated_date,
          :exDate => res.expiration_date,
          :reg_status => res.reg_status,
          :first_bill => res.first_bill,
          :recur_bill => res.recur_bill,
          :auto_bill  => res.auto_bill,
          :auto_period => res.auto_period,
          :next_bill  => res.next_bill,
          :next_period => res.next_period,
          :renew_not_required => res.renew_not_required,
          :notes => res.notes,
          :reseller => res.reseller,
          :ds => res.ds
        }
      end
      def old_info_contact(res)
        {
          :id => res.id,
          :roid => res.roid,
          :status => res.status[0],
          :postal_info => res.postal_info,
          :voice => res.voice,
          :email => res.email,
          :clID => res.client_id,
          :crID => res.creator_id,
          :crDate => res.created_date,
          :type => res.type,
          :trad_name => res.trad_name,
          :co_no => res.co_no,
          :opt_out => res.opt_out
        }
      end
      def old_info_host(res)
        addrs = res.addresses.try(:dup) || {}
        addrs[:v4] = addrs['ipv4']
        addrs[:v6] = addrs['ipv6']

        {
          :name => res.name,
          :roid => res.roid,
          :status => res.status[0],
          :clID => res.client_id,
          :crID => res.creator_id,
          :crDate => res.created_date,
          :addr => addrs
        }
      end
  end  
end
