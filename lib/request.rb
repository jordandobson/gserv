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