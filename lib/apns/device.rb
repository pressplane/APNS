module APNS
  
  class Device
    attr_accessor :token
    
    def initialize(device_token)
      # cleanup token
      self.token = device_token.gsub(/[\s|<|>]/,'')
    end
    
    def to_payload
      [token].pack('H*')
    end 
  end

end