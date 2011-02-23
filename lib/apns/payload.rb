module APNS
    
  class Payload
    attr_accessor :device, :message
    
    APS_ROOT = :aps
    APS_KEYS = [:alert, :badge, :sound]
    
    PAYLOAD_MAX_SIZE = 256
        
    def initialize(device_token, message_string_or_hash = {})
      self.device = APNS::Device.new(device_token)
      if message_string_or_hash.is_a?(String)
        self.message = {:alert => message_string_or_hash.strip}
      elsif message_string_or_hash.is_a?(Hash)
        self.message = message_string_or_hash.each_value { |val| val.strip! if val.respond_to? :strip! }
      else
        raise "Payload message argument needs to be either a hash or a string"
      end
      self
    end
    
    #
    # Handy chainable setters
    # 
    # Ex: APNS::Payload.new(token).badge(3).sound("bipbip").alert("Roadrunner!")
    #
    def badge(number)
      message[:badge] = number
      self
    end
    
    def sound(filename)
      message[:sound] = filename
      self
    end
    
    def alert(string)
      message[:alert] = string
      self
    end
     
    
    # 
    def to_ssl
      pm = self.apn_message.to_json
      [0, 0, 32, self.device.to_payload, 0, pm.size, pm].pack("ccca*cca*")
    end
    
    def size
      self.to_ssl.size
    end
    
    def valid?
      self.size <= PAYLOAD_MAX_SIZE
    end
    
    def apn_message
      message_hash = message.dup
      apnm = { APS_ROOT => {} }
      APS_KEYS.each do |k|
        apnm[APS_ROOT][k] = message_hash.delete(k) if message_hash.has_key?(k)
      end
      apnm.merge!(message_hash)
      apnm
    end
    
    # Returns a new payload with the alert truncated to fit in the payload size requirement (PAYLOAD_MAX_SIZE)
    # Rem: It's a best effort since the alert may not be the one string responsible for the oversized payload
    def payload_with_truncated_alert
      payload_with_truncated_string_at_keypath([:alert])
    end
    
    
    # payload_with_truncated_string_at_keypath("alert") or payload_with_truncated_string_at_keypath([:alert])
    #   or
    # payload_with_truncated_string_at_keypath("custom1.custom2") or payload_with_truncated_string_at_keypath([:custom1, :custom2])
    # Rem: Truncation only works on String values...
    def payload_with_truncated_string_at_keypath(array_or_dotted_string)
      return self if valid? # You can safely call it on a valid payload 
      
      # Rem: I'm using Marshall to make a deep copy of the message hash. Of course this would only work with "standard" values like Hash/String/Array
      payload_with_empty_string = APNS::Payload.new(device.token, Marshal.load(Marshal.dump(message)).at_key_path(array_or_dotted_string){|obj, key| obj[key] = ""})
      wanted_length = PAYLOAD_MAX_SIZE - payload_with_empty_string.size

      # Return a new payload with truncated value
      APNS::Payload.new(device.token, Marshal.load(Marshal.dump(message)).at_key_path(array_or_dotted_string) {|obj, key| obj[key] = obj[key].truncate(wanted_length) })
    end
            
  end #Payload
    
end #module

class Hash
  def at_key_path(array_or_dotted_string, &block)
    keypath = array_or_dotted_string.is_a?(Array) ? array_or_dotted_string.dup : array_or_dotted_string.split('.')
    obj = self
    while (keypath.count > 0) do
      key = keypath.shift.to_s
      key = key.to_sym if !obj.has_key?(key) && obj.has_key?(key.to_sym)
      next unless keypath.count > 0 # exit the while loop
      obj = obj.has_key?(key) ? obj[key] : raise("No key #{key} in Object (#{obj.inspect})")
    end

    raise("No key #{key} in Object (#{obj.inspect})") unless obj.has_key?(key)
    if block_given? 
      block.call(obj, key)
      return self
    else
      return obj[key]
    end
  end    
end

class String
  if !String.new.respond_to? :truncate
    def truncate(len)
       (len > 4 && length > 5) ? self[0..(len - 1) - 3] + '...' : self
    end
  end
end
