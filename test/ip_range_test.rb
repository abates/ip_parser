require 'test_helper'

class IpRangeTest < Test::Unit::TestCase
  def test_v6_address
    assert_nothing_raised ArgumentError do
      ip_range1 = IpParser::IpRange.new("127::1")
      ip_range1 = IpParser::IpRange.new("fe80::216:3eff:fe6d:24a3")
      ip_range2 = IpParser::IpRange.new("fe80::/24")
      ip_range3 = IpParser::IpRange.new("fe80::216:3eff:fe6d:24a3-2500")
    end
  end

  def test_adjacent_ip
    ip_range1 = IpParser::IpRange.new("192.168.0.0/25")
    ip_range2 = IpParser::IpRange.new("192.168.0.128/25")
    assert(ip_range1.adjacent?(ip_range2))
    ip_range2 = IpParser::IpRange.new("192.168.1.128/25")
    assert(!ip_range1.adjacent?(ip_range2))
  end

  def test_contains_ip
    ip_range1 = IpParser::IpRange.new("192.168.0.0/25")
    ip_range2 = IpParser::IpRange.new("192.168.0.1/32")
    assert(ip_range1.contains?(ip_range2))
  end

  def test_any_ip
    ip_range1 = IpParser::IpRange.new("any");
    assert(ip_range1.ip_start == IPAddr.new("0.0.0.0"))
    assert(ip_range1.ip_end == IPAddr.new("255.255.255.255"))
  end
end
