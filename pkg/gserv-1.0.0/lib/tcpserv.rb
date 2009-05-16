require 'socket'
require 'request'
require 'response'
require 'servlets'

class Tcpserv

  VERSION = '1.0.0'
  CRLF    = "\r\n"
  ROOT    = "test/assets"
  
  def initialize(port=12321, *args)
    @server = TCPServer.new(port)
    @request  = Request.new CRLF
    @response = Response.new ROOT, CRLF
    @t_pool = Array.new
  end  
  
  def run
    while session = @server.accept
      @t_pool << Thread.new(session) do |sess|
        req = @request.http_in sess
        @response.path = req
        res = @response.give_response
        puts res
        my_session.close
      end
      @t_pool.pop
    end
  end

  
end

