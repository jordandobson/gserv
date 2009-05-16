require 'gserver'
require 'erb'

class Response

  attr_accessor :path, :root, :crlf
  
  def initialize server, root, crlf
    @server = server
    @root   = root
    @crlf = crlf
  end
  
  def give_response
    begin
     servlet = parse_for_servlet
     r = ""
     if servlet
      r = "HTTP/1.1 200 OK#{@crlf}#{servlet}"
     else
       file = parse_for_file
       if file
         r << "HTTP/1.1 200 OK#{@crlf}"
         r << "Date: #{request_date}#{@crlf}"
         r << "Content-Length: #{file.length}#{@crlf}"
         r << "Content-Type: text/html#{@crlf}"
         r << "#{@crlf}#{file}"
       else
         r = "HTTP/1.1 404 Not Found"
       end
     end
   rescue
     r = "HTTP/1.1 500 Internal Server Error"
   end
   r
  end

  def parse_for_servlet
    path = @path.sub(/^\/|\/$/, "")
    begin
      if @server::Servlets::SERVS.include? path
        eval("#{@server}::Servlets.#{path}")
      else
        false
      end
    rescue
      raise 500
    end
  end
 
  def parse_for_file
    begin
      root_path = "#{@root}#{@path}"
      if File.exist?(root_path)
        if root_path =~ /.+[.]erb$/
          ERB.new(IO.read(root_path)).result(binding)
        else
          IO.read(root_path)
        end
      else
        false
      end
    rescue
      raise 500
    end
  end
  
  def request_date
    Time.now.strftime("%a, %d %b %Y %H:%M:%S %Z")
  end

end

class Request

  attr_accessor :path, :crlf
  
  def initialize crlf
    @crlf = crlf
  end 

  def http_in io
    req = ""
    io.each_line do |l|
      break if l == @crlf
      req << l
    end
    parse req
  end
  
  def parse req
    req.each_line do |l|
      l.strip!
      if l =~ /GET (\/[^\s]*) HTTP\/\d.\d/
        @path = $1
      end
    end
    @path
  end 

end

class Gserv < GServer 

  VERSION = '1.0.0'
  CRLF    = "\r\n"
  ROOT    = "test/assets" 
  
  def initialize(port=12321, *args)
    super
    @request  = Request.new CRLF
    @response = Response.new Gserv, ROOT, CRLF
  end
  
  def serve(io)
    req = @request.http_in io
    @response.path = req
    res = @response.give_response
    io.puts res
  end
  
end

class Gserv
  class Servlets
  
    SERVS     = %w{do500 time}
    
    def self.do500
      raise 500
    end
    
    def self.time
      "The time is: #{Time.now}"
    end
  end
end
