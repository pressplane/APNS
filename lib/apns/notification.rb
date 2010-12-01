module APNS
  
  class Notification
    attr_accessor :device, :message
    
    # Short-cut to create a payload from a token String and a message (Hash or String)
    # APNS::Notification.to_payload(a_token, a_message)
    def self.to_payload(device_token, message_string_or_hash)
      notification = self.new(device_token, message_string_or_hash)
      notification.to_payload
    end
    
    def initialize(device_token, message_string_or_hash)
      self.device = APNS::Device.new(device_token)
      if message_string_or_hash.is_a?(String)
        self.message = {:alert => message_string_or_hash}
      elsif message_string_or_hash.is_a?(Hash)
        self.message = message_string_or_hash
      else
        raise "Notification needs to have either a hash or string"
      end
    end
        
    def to_payload
      pm = self.packaged_message
      [0, 0, 32, self.device.to_payload, 0, pm.size, pm].pack("ccca*cca*")
    end
    
    def valid?
      return self.class.valid_payload?(self.to_payload)
    end
    
    def self.valid_payload?(payload)
      return payload.size.to_i <= 256
    end
    
    def packaged_message
      message_hash = message
      aps = {'aps'=> {} }
      [:alert, :badge, :sound].each do |k|
        aps['aps'][k] = message_hash.delete(k) if message_hash.has_key?(k)
      end
      aps.merge!(message_hash)
      aps.to_json
    end
    
  end
end
