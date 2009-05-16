require "uri"
require "test/unit"
require "gserv"
require "net/http"

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
    assert_equal '/',   @server.path
    assert_equal '1.1', @server.protocol
  end
 
end