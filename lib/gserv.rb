require 'gserver'
require 'erb'

class Gserv < GServer 

  VERSION = '1.0.0'
  CRLF    = "\r\n"
  ROOT    = "test/assets"
  
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
   begin
     servlet = parse_for_servlet
     r = ""
     if servlet
      r = "HTTP/1.1 200 OK#{CRLF}#{servlet}"
     else
       file = parse_for_file
       if file
         r << "HTTP/1.1 200 OK#{CRLF}"
         r << "Date: #{request_date}#{CRLF}"
         r << "Content-Length: #{file.length}#{CRLF}"
         r << "Content-Type: text/html#{CRLF}"
         r << "#{CRLF}#{file}"
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
      if Servlets::SERVS.include? path
        Servlets.instance_eval(path)
      else
        false
      end
    rescue
      raise 500
    end
  end
 
  def parse_for_file
    begin
      root_path = "#{ROOT}#{@path}"
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

class Gserv
  class Servlets
  
    SERVS = %w{do500 time}
  
    def self.do500
      raise 500
    end
    
    def self.time
      "The time is: #{Time.now}"
    end
  
  end
end
