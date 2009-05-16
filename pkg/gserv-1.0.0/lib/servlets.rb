class Servlets
  SERVS     = %w{do500 time}
  
  def self.do500
    raise 500
  end
  
  def self.time
    "The time is: #{Time.now}"
  end
end