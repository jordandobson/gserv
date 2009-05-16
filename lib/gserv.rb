require 'gserver'
require 'request'
require 'response'
require 'servlets'

class Gserv < GServer 

  VERSION = '1.0.0'
  CRLF    = "\r\n"
  ROOT    = "test/assets" 
  
  def initialize(port=12321, *args)
    super
    @request  = Request.new CRLF
    @response = Response.new ROOT, CRLF
  end
  
  def serve(io)
    req = @request.http_in io
    @response.path = req
    res = @response.give_response
    io.puts res
  end
  
end
