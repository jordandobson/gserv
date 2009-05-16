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
  
  def test_request_time
    @server.start
    res = Net::HTTP.get_response URI.parse("http://localhost:#{@port}/time")
    assert_equal "200", res.code
    assert Time.parse(res.body)
    @server.stop
  end
  
  def test_request_returns_404
    @server.start
    res = Net::HTTP.get_response URI.parse("http://localhost:#{@port}/do404")
    assert_equal "404", res.code
    @server.stop
  end
  
  def test_missing_servlet_returns_500
    @server.start
    res = Net::HTTP.get_response URI.parse("http://localhost:#{@port}/do500")
    assert_equal "500", res.code
    @server.stop
  end

  def test_request_returns_html
    @server.start
    res = Net::HTTP.get_response URI.parse("http://localhost:#{@port}/hello.html")
    expected = IO.read("#{File.dirname(__FILE__)}/assets/hello.html")
    assert_equal "200", res.code
    assert_equal expected, res.body
    @server.stop
  end
  
  def test_request_returns_erb
    @server.start
    res = Net::HTTP.get_response URI.parse("http://localhost:#{@port}/hello.html.erb")
    expected = IO.read("#{File.dirname(__FILE__)}/assets/hello.html")
    assert_equal "200", res.code
    assert_equal expected, res.body
    @server.stop
  end
  
  def test_request_bad_erb_returns_500
    @server.start
    res = Net::HTTP.get_response URI.parse("http://localhost:#{@port}/bad_erb.erb")
    assert_equal "500", res.code
    @server.stop
  end

end