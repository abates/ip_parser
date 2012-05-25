require 'test_helper'

class PortCollectionTest < Test::Unit::TestCase
  def test_valid_port
    assert_nothing_raised RuntimeError do
      IpParser::PortCollection.new("22-26")
      IpParser::PortCollection.new("any")
      IpParser::PortCollection.new("")
    end
  end

  def test_invalid_port
    assert_raise RuntimeError do
      IpParser::PortCollection.new("-1")
    end
    assert_raise RuntimeError do
      IpParser::PortCollection.new("65536")
    end
  end

  def test_valid_range
    assert_nothing_raised RuntimeError do
      IpParser::PortCollection.new("1-2")
      IpParser::PortCollection.new("1-2, 3-4 10-22\n1024-65535")
    end
  end

  def test_invalid_range
    assert_raise RuntimeError do
      IpParser::PortCollection.new("65535-65536")
    end
    assert_raise RuntimeError do
      IpParser::PortCollection.new("-1-35")
    end
  end

  def test_minimize
    #IpParser::PortCollection.new("1-22, 23-30, 40-50, 52-53, 54-60").minimize.each do |port|
    #  print port.to_s + "\n"
    #end
    ports = IpParser::PortCollection.new("1-22, 23-30, 40-50, 52-53, 54-60").minimize
    assert_equal ports.shift, IpParser::PortRange.new("1-30")
    assert_equal ports.shift, IpParser::PortRange.new("40-50")
    assert_equal ports.shift, IpParser::PortRange.new("52-60")
  end

  def test_contains
    col1 = IpParser::PortCollection.new("22")
    col2 = IpParser::PortCollection.new("22")
    col1 = IpParser::PortCollection.new("1-65535")
    port = col1.minimize.first
    col2 = IpParser::PortCollection.new("#{port.port_start}-#{port.port_end}")
    assert(col2.contains?(col1))
  end
end
