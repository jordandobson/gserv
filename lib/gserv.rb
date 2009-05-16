require 'gserver'
require 'erb'

class Gserv < GServer 

  VERSION = '1.0.0'
  CRLF = "\r\n"
  
  attr_accessor :path, :protocol, :headers, :servlets 
  
  def initialize(port=12321, *args)
    super
    @servlets = {}
  end
  
  def serve(io)
    req = http_in io
    res = check_request
    io.puts res
  end
  
  def http_in io
    req = ""
    io.each_line do |l|
      break if l == CRLF
      req << l
    end
    parse req
  end
  
  def parse req
    @headers = {}
    req.each_line do |l|
      l.strip!
      if l =~ /GET (\/[^\s]*) HTTP\/(\d.\d)/
        @path       = $1
        @protocol   = $2
      elsif l =~ /(.+): (.+)/
        @headers[$1] = $2
      end
    end
  end
  
  def check_request
    case @path
    when "/404"
      "HTTP/1.1 404 Not Found"
    when "/500"
      "HTTP/1.1 500 Internal Server Error"
    else
      "HTTP/1.1 200 OK"
    end
  end
    
end