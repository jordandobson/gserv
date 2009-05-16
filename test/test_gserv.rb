require "uri"
require "test/unit"
require "gserv"
require "net/http"
require "time"

class TestGserv < Test::Unit::TestCase

  def setup
    @port = 12321
    @server = Gserv.new(@port)
    
  end
  
  def teardown
    @server.stop
  end
  
  def test_start_and_stop_server
    assert @server.stopped?
    @server.start
    assert !@server.stopped?
    @server.stop
    assert @server.stopped?
  end
  
  def test_request
    @server.start
    res = Net::HTTP.get_response URI.parse("http://localhost:#{@port}")
    assert_equal "200", res.code
    assert_equal '/',   @server.path
    assert_equal '1.1', @server.protocol
  end
  
  def test_request_time
    @server.start
    res = Net::HTTP.get_response URI.parse("http://localhost:#{@port}/time")
    assert_equal "200", res.code
    assert Time.parse(res.body)
  end
  
  def test_request_raises
    @server.start
    res = Net::HTTP.get_response URI.parse("http://localhost:#{@port}/404")
    assert_equal "404", res.code
  end
  
  def test_request_raises
    @server.start
    res = Net::HTTP.get_response URI.parse("http://localhost:#{@port}/500")
    assert_equal "500", res.code
  end
 
end