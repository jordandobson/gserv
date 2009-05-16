require 'socket'
require 'request'
require 'response'
require 'servlets'

class TcpServ < TCPServer

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
# 
# 
# # require 'socket'
# # ### 
# # # Server code 
# # # 
# # server = TCPServer.new(12321) 
# # while session = server.accept 
# #   Thread.new(session) do |my_session| 
# #     my_session.puts Time.new 
# #     my_session.close 
# #   end
# # end 
