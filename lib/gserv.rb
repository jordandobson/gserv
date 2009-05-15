require 'gserver'

class Gserv < GServer 

  VERSION = '1.0.0'
  
  def serve(io)
    io.puts(Time.now.to_s)
  end

end