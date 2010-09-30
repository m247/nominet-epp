module NominetEPP
  module Operations
    # EPP Merge Operation
    module Merge
      # Merge accounts or domains into an Account
      #
      # @param [String] target Account ID to merge into
      # @param [Hash] sources Account IDs to merge into the target
      # @option sources [Array] :accounts Account numbers to merge
      # @option sources [Array] :names Account names to merge
      # @option sources [Array] :domains Domain names to merge
      # @return [false] merge failed
      # @return [Response] merge succeded
      def merge(target, sources = {})
        resp = @client.update do
          account('merge') do |node, ns|
            node << XML::Node.new('roid', target, ns)

            (sources[:accounts] || []).each do |acct|
              n = XML::Node.new('roid', acct, ns)
              n['source'] = 'y'
              node << n
            end

            (sources[:names] || []).each do |name|
              node << XML::Node.new('name', name, ns)
            end

            (sources[:domains] || []).each do |domain|
              node << XML::Node.new('domain-name', domain, ns)
            end
          end
        end

        return false unless resp.success?

        resp  # Need to test this to see what gets returned
      end
    end
  end
end
