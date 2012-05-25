require 'test_helper'

class IpCollectionTest < Test::Unit::TestCase
  def test_valid_ip
    assert_nothing_raised ArgumentError do
      IpParser::IpCollection.new("192.168.1.0")
      IpParser::IpCollection.new("any")
      IpParser::IpCollection.new("")
    end
  end

  def test_invalid_ip
    assert_raise ArgumentError do
      IpParser::IpCollection.new("192.168.1")
    end
    assert_raise ArgumentError do
      IpParser::IpCollection.new("192.168.1.256")
    end
    assert_raise ArgumentError do
      IpParser::IpCollection.new("192.168.1.1.1")
    end
  end

  def test_valid_range
    assert_nothing_raised ArgumentError do
      IpParser::IpCollection.new("127::1")
      IpParser::IpCollection.new("192.168.1.0-10")
      IpParser::IpCollection.new("192.168.1.0-192.168.2.255")
      IpParser::IpCollection.new("192.168.1.0-255")
      IpParser::IpCollection.new("192.168.1.0-192.168.0.0")
      IpParser::IpCollection.new("192.168.1.0/24\n192.168.2.0/24\n 192.168.5.37-192.168.8.201")
      IpParser::IpCollection.new("192.168.1.0/24, 192.168.2.0/24, 192.168.5.37-192.168.8.201")
      IpParser::IpCollection.new("192.168.1.0/24 192.168.2.0/24 192.168.5.37-192.168.8.201")
    end
  end

  def test_invalid_range
    assert_raise ArgumentError do
      IpParser::IpCollection.new("192.168.1.0-256")
    end
    assert_raise ArgumentError do
      IpParser::IpCollection.new("192.168.1.0-1.255")
    end
  end

  def test_valid_cidr
    assert_nothing_raised ArgumentError do
      IpParser::IpCollection.new("192.168.0.0/16")
      IpParser::IpCollection.new("192.168.1.0/24")
      IpParser::IpCollection.new("192.168.1.0/30")
      IpParser::IpCollection.new("192.168.1.0/31")
      IpParser::IpCollection.new("192.168.1.1/32")
    end
  end

  def test_invalid_cidr
    assert_raise ArgumentError do
      IpParser::IpCollection.new("192.168.1.0/33")
    end
    assert_raise ArgumentError do
      IpParser::IpCollection.new("192.168.1.1/24")
    end
  end

  def test_valid_netmask
    assert_nothing_raised ArgumentError do
      IpParser::IpCollection.new("192.168.1.0/255.255.255.0")
      IpParser::IpCollection.new("192.168.0.0/255.255.0.0")
    end
  end

  def test_invalid_netmask
    assert_raise ArgumentError do
      IpParser::IpCollection.new("192.168.1.0/255.255.0.0")
      IpParser::IpCollection.new("192.168.1.0/255.255.256.0")
    end
  end

  def test_minimize
    #IpParser::IpCollection.new("192.168.1.0/24\n192.168.2.0/24\n192.168.5.37-192.168.8.201").minimize.each do |ip|
    #  print ip.to_s + "/" + ip.netmask.to_s + "\n"
    #end
    parser = IpParser::IpCollection.new("127::1")
    networks = parser.minimize
    assert_equal IPAddr.new("127::1/128"), networks.shift

    parser = IpParser::IpCollection.new("192.168.1.1")
    networks = parser.minimize
    assert_equal networks.shift, IPAddr.new("192.168.1.1/255.255.255.255")

    parser = IpParser::IpCollection.new("192.168.5.37-192.168.8.201")
    networks = parser.minimize
    assert_equal networks.shift, IPAddr.new("192.168.5.37/255.255.255.255")
    assert_equal networks.shift, IPAddr.new("192.168.5.38/255.255.255.254")
    assert_equal networks.shift, IPAddr.new("192.168.5.40/255.255.255.252")
    assert_equal networks.shift, IPAddr.new("192.168.5.44/255.255.255.252")
    assert_equal networks.shift, IPAddr.new("192.168.5.48/255.255.255.248")
    assert_equal networks.shift, IPAddr.new("192.168.5.56/255.255.255.248")
    assert_equal networks.shift, IPAddr.new("192.168.5.64/255.255.255.240")
    assert_equal networks.shift, IPAddr.new("192.168.5.80/255.255.255.240")
    assert_equal networks.shift, IPAddr.new("192.168.5.96/255.255.255.224")
    assert_equal networks.shift, IPAddr.new("192.168.5.128/255.255.255.192")
    assert_equal networks.shift, IPAddr.new("192.168.5.192/255.255.255.192")
    assert_equal networks.shift, IPAddr.new("192.168.6.0/255.255.255.128")
    assert_equal networks.shift, IPAddr.new("192.168.6.128/255.255.255.128")
    assert_equal networks.shift, IPAddr.new("192.168.7.0/255.255.255.0")
    assert_equal networks.shift, IPAddr.new("192.168.8.0/255.255.255.128")
    assert_equal networks.shift, IPAddr.new("192.168.8.128/255.255.255.192")
    assert_equal networks.shift, IPAddr.new("192.168.8.192/255.255.255.248")
    assert_equal networks.shift, IPAddr.new("192.168.8.200/255.255.255.254")
  end

  def test_contains
    col1 = IpParser::IpCollection.new("192.168.1.0/24\n192.168.2.0/24\n192.168.5.37-192.168.8.201");
    col2 = IpParser::IpCollection.new("192.168.1.128/30\n192.168.2.0/25\n192.168.5.37/32\n192.168.8.0/25");
    col3 = IpParser::IpCollection.new("192.168.1.128/30\n192.168.2.0/25\n192.168.5.36/32\n192.168.8.0/25");

    col4 = IpParser::IpCollection.new("192.168.1.0/24\n192.168.2.0/24\n192.168.5.37-192.168.8.201\n192.168.42.0/24");
    col5 = IpParser::IpCollection.new("192.168.0.0/22\n192.168.5.37-192.168.8.201");

    assert(col1.contains?(col2))
    assert(!col1.contains?(col3))

    assert(col4.extra?(col1))
    assert(!col5.extra?(col1))

    assert(col1.contains?("192.168.1.127"))
  end

  def test_complement
    col1 = IpParser::IpCollection.new("192.168.1.0-192.168.1.4")
    col2 = IpParser::IpCollection.new("192.168.1.0/30 192.168.1.4/32")
    complement = col1.complement(col2)
    assert complement.empty?

    complement = col2.complement(col1)
    assert complement.empty?
  end

  def test_remove
    col1 = IpParser::IpCollection.new("192.168.1.0/24")
    col2 = IpParser::IpCollection.new("192.168.1.128")
    col1.remove(col2)
    networks = col1.minimize
    assert_equal IPAddr.new("192.168.1.0/255.255.255.128"), networks.shift
    assert_equal IPAddr.new("192.168.1.129/255.255.255.255"), networks.shift
    assert_equal IPAddr.new("192.168.1.130/255.255.255.254"), networks.shift
    assert_equal IPAddr.new("192.168.1.132/255.255.255.252"), networks.shift
    assert_equal IPAddr.new("192.168.1.136/255.255.255.248"), networks.shift
    assert_equal IPAddr.new("192.168.1.144/255.255.255.240"), networks.shift
    assert_equal IPAddr.new("192.168.1.160/255.255.255.224"), networks.shift
    assert_equal IPAddr.new("192.168.1.192/255.255.255.192"), networks.shift

    col1 = IpParser::IpCollection.new("192.168.1.0/24")
    col2 = IpParser::IpCollection.new("")
    col1.remove(col2)
    networks = col1.minimize
    assert_equal IPAddr.new("192.168.1.0/255.255.255.0"), networks.shift

    col1 = IpParser::IpCollection.new("192.168.1.0/24")
    col2 = IpParser::IpCollection.new("")
    col2.remove(col1)
    networks = col2.minimize
    assert_equal 0, networks.size
  end
end
