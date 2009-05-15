require "test/unit"
require "gserv"

class TestGserv < Test::Unit::TestCase

  def setup
    @port = 1234
    @server = Gserv.new(@port)
  end
  
  def test_start_and_stop_server
    @server.start
    assert GServer.in_service?(@port)
    @server.stop
  end

end
