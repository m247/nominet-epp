module NominetEPP
  module Operations
    # EPP Check Operation
    module Check
      # Check the availablity of one or more domain names
      #
      # @param [String, ...] names List of names to check
      # @return [false] request failed
      # @return [true] the domain name is available
      # @return [Hash<String,Boolean>] availability by domain name
      def check(*names)
        @resp = @client.check do
          domain('check') do |node, ns|
            names.each do |name|
              node << XML::Node.new('name', name, ns)
            end
          end
        end

        return false unless @resp.success?

        @check_limit = check_abuse_limit(@resp.data)
        results = @resp.data.find('//domain:name', namespaces)
        if results.size > 1
          hash = {}
          results.each {|node| hash[node.content.strip] = (node['avail'] == '1') }
          hash
        else
          results.first['avail'] == '1'
        end
      end

      protected
        def check_abuse_limit(data)
          data.find('//domain:chkData/@abuse-limit', namespaces).first.value.to_i
        end
    end
  end
end
