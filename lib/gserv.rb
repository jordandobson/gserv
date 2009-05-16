require 'gserver'

class Gserv < GServer 

  VERSION = '1.0.0'
  CRLF = "\r\n"
  
  attr_accessor :path, :protocol, :headers  
  
  def initialize(port=12321, *args)
    super
  end
  
  def serve(io)
    req = http_in io
    io.puts(req)
  end
  
  def http_in io
    req = ""
    io.each_line do |l|
      break if l == CRLF
      req << l
    end
    puts "------"
    puts req
    puts "------"
    parse req
    "HTTP/1.1 200 OK"
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

end
