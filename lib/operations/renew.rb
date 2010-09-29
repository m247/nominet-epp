module NominetEPP
  module Operations
    # EPP Renew Operation
    module Renew
      # Renew a domain name
      #
      # @param [String] name Domain name to renew
      # @param [String] period Length of time to renew for. Currently has to be '2y'.
      # @raise [ArgumentError] invalid period specified
      # @raise [RuntimeError] renewed domain name does not match +name+
      # @return [false] renewal failed
      # @return [Time] domain expiration date
      def renew(name, period = '2y')
        period = '2y'  # reset period to 2 years as nominet don't currently support other options

        unit = period[-1..1]
        num = period.to_i.to_s

        raise ArgumentError, "period suffix must either be 'm' or 'y'" unless %w(m y).include?(unit)

        resp = @client.renew do
          domain('renew') do |node, ns|
            node << XML::Node.new('name', name, ns)
            p = XML::Node.new('period', num, ns);
            p['unit'] = unit
            node << p
          end
        end

        return false unless resp.success?

        renName = node_value(resp.data, '//domain:renData/domain:name')
        renExp  = node_value(resp.data, '//domain:renData/domain:exDate')

        raise "Renewed name #{renName} does not match #{name}" if renName != name
        return Time.parse(renExp)
      end
    end
  end
end
