require 'erb'
class Response

  attr_accessor :path, :root, :crlf
  
  def initialize root, crlf
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
      if Servlets::SERVS.include? path
        eval("Servlets.#{path}")
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
