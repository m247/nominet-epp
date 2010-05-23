module NominetEPP
  module Operations
    module Merge
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
