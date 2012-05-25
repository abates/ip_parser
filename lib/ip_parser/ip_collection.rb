require "ip_parser/generic_collection"
require "ip_parser/ip_range"
require "set"

module IpParser
class IpCollection < GenericCollection
  attr_accessor :ips

  def initialize(values=[])
    loopback = false
    @ips = Set.new
    if (values.is_a? Array)
      values.each do |address|
        unless (address.is_a? IpRange)
          address = IpRange.new(address)
        end
        @ips.add address
      end
    elsif (! values.nil?)
      values.split(/[,\r\n\s]+/).each do |address|
        if (address =~ /^127::1/)
          loopback = true
        end
        address = address.strip
        next if (address.empty?)
        @ips.add(IpRange.new(address))
      end
    end

    ips = Set.new
    minimize.each do |ipaddr|
      ips.add(IpRange.new(ipaddr))
    end
    @ips = ips
  end

  def remove ip
    if (ip.is_a?(IpCollection))
      ips = ip.minimize
    elsif ip.is_a?(IpRange)
      ips = IpCollection.new(ip).minimize
    else
      ips = [IPAddr.new(ip)]
    end
    if (ips.size > 0)
      old_ips = minimize
      new_ips = Set.new
      ips.each do |oip|
        old_ips.each do |iip|
          if (iip.contains?(iip))
            new_ips << IpRange.new("#{iip.to_s}-#{IPAddr.new(oip.to_i - 1, oip.family).to_s}")
            new_ips << IpRange.new("#{IPAddr.new(oip.broadcast.to_i + 1, oip.family).to_s}-#{iip.broadcast.to_s}")
          elsif (! oip.contains?(oip))
            new_ips << IpRange.new(oip)
          end
        end
      end
      @ips = new_ips
    end
  end

  def add(ip)
    if (ip.is_a?(IpCollection))
      @ips.merge(ip.ips)
    elsif (ip.is_a?(Array))
      ip.each do |i|
        @ips.add(IpRange.new(i))
      end
    else
      @ips.add(IpRange.new(ip))
    end
  end

  def complement ip_collection
    return subtract_rhs(ip_collection.ips, @ips)
  end

  def contains? ip_collection
    if (ip_collection.is_a?(IpCollection))
      return complement(ip_collection).size == 0
    else
      return complement(IpCollection.new(ip_collection)).size == 0
    end
  end

  def extra? ip_collection
    return extra(ip_collection).size != 0
  end

  def extra ip_collection
    return subtract_lhs(@ips, ip_collection.ips)
  end

  def minimize
    minimum_ranges = Array.new
    minimum_networks = Array.new
    last_range = nil
    # combine adjacent ranges and remove
    # ranges contained within other ranges
    @ips.sort.each do |ip_range|
      #print "Minimizing next IP: " + ip_range.to_s + "\n"
      if (last_range.nil?)
        minimum_ranges.push(ip_range)
        last_range = ip_range
      elsif (! last_range.contains?(ip_range))
        if (last_range.adjacent?(ip_range))
          last_range.ip_end = ip_range.ip_end
        else 
          minimum_ranges.push(ip_range)
          last_range = ip_range
        end
      end
    end

    minimum_ranges.each do |ip_range|
      minimum_networks.concat(ip_range.networks)
    end

    return minimum_networks
  end

  def to_s
    @ips.to_a.join(", ")
  end

  def each
    @ips.each do |ip|
      yield ip
    end
  end
end
end

