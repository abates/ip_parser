require 'test_helper'

class PortRangeTest < Test::Unit::TestCase
  def test_adjacent_port
    port_range1 = IpParser::PortRange.new("1-25")
    port_range2 = IpParser::PortRange.new("26-30")
    assert(port_range1.adjacent?(port_range2))
    port_range2 = IpParser::PortRange.new("27-30")
    assert(!port_range1.adjacent?(port_range2))
  end

  def test_contains_port
    port_range1 = IpParser::PortRange.new("1-25")
    port_range2 = IpParser::PortRange.new("22-23")
    assert(port_range1.contains?(port_range2))
    port_range1 = IpParser::PortRange.new("22")
    port_range2 = IpParser::PortRange.new("22")
    assert(port_range1.contains?(port_range2))
  end
end
