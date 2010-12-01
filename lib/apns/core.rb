module APNS
  require 'socket'
  require 'openssl'
  require 'json'
  
  class PemPathError < RuntimeError;end
  class PemFileError < RuntimeError;end
  class SendError < RuntimeError;end
  

  @host = 'gateway.sandbox.push.apple.com'
  @port = 2195
  # openssl pkcs12 -in mycert.p12 -out client-cert.pem -nodes -clcerts
  @pem = nil # this should be the path of the pem file not the contentes
  @pass = nil
    
  class << self
    attr_accessor :host, :pem, :port, :pass
  end 
  
  # send one or many payloads, optionaly use an existing connection if specified
  # by default, it assumes the first parameter is either a payload String or an Array of payload Strings
  # However, you can pass a collection of anonymous objects as first parameter as long as you provide the right 
  # :to_payload Proc to get a payload from the object. The :to_payload Proc must output a valid payload.
  #
  # Callback
  #   When the payload has successfuly been sent you may specify a :sent (Proc) callback to be called with the object as parameter
  #   
  # Connection
  #   If you need to use an already existing connection, just pass a :connection parameter. This parameter is either a Array
  #   which has two elements: [sock, ssl] as returned by the open_connection method or a Proc which returns and Array with [sock, ssl]
  #
  # Errors
  #   If an error occures during the write operation, the socket and ssl connections are closed and "APNS::Send::Error" is raised
  #
  # Example:
  #
  #  single payload
  # APNS.send_payload(payload)
  #
  #  or with multiple payloads
  # APNS.send_payload([payload1, payload2])
  #
  #  or with notification objects
  # APNS.send_payload(notifications, :to_payload => lambda{|n| n.to_payload})
  #
  #  or with notification objects, connection reuse and sent proc
  # APNS.send_payload(notifications, 
  #              :connection => lambda{ recreate_connection_if_needed() }, 
  #              :sent => lambda{|n| n.update_attribute(:sent_at, Time.now)}, 
  #              :to_payload => lambda{|n| n.to_payload}
  #              )
                
  def self.send_payload(collection, options = {})
    # accept Array or single payload
    notifications = collection.is_a?(Array) ? collection : [collection]
    
    # check sent option
    if options[:sent]
      raise "send_payload: :sent must be a Proc" unless options[:sent].is_a?(Proc)
    end
    
    #check to_payload option
    if options[:to_payload]
      raise "send_payload: :to_payload must be a Proc" unless options[:to_payload].is_a?(Proc)
    end
    
    # check connection option  
    if options[:connection]
      if options[:connection].is_a?(Proc)
        sock, ssl = options[:connection].call
      elsif options[:connection].is_a?(Array)
        sock, ssl = options[:connection]
      else
        raise "send_payload: :connection must be either a Proc returning sock, ssl or an Array with sock and ssl!"
      end
      should_close = false
    else  
      sock, ssl = self.push_connection
      should_close = true  
    end
    raise "send_payload: ssl connection should respond to #close" unless ssl.respond_to?(:close)
    raise "send_payload: sock connection should respond to #close" unless sock.respond_to?(:close)
    
    # loop 
    notifications.each do |notification|
      if options[:to_payload]
        payload = options[:to_payload].call(notification)
      else
        payload = notification
      end
      
      unless APNS::Notification.valid_payload?(payload)
        puts "send_payload: Invalid payload in notification: #{notification.to_s} (#{payload})"
        next
      end
      
      begin
        ssl.write(payload)
        ssl.flush
      rescue
        ssl.close
        sock.close
        raise APNS::SendError
      end
      
      if options[:sent]
        options[:sent].call(notification)
      end
      
    end

    # cleanup if needed
    if should_close
      ssl.close
      sock.close
    end
  end
  
    
  def self.feedback
    sock, ssl = self.feedback_connection
    
    apns_feedback = []
    
    while line = sock.gets   # Read lines from the socket
      line.strip!
      f = line.unpack('N1n1H140')
      apns_feedback << [Time.at(f[0]), f[2]]
    end
    
    ssl.close
    sock.close
    
    return apns_feedback
  end
    
  
  protected
    
  def self.push_connection
    raise PemPathError, "The path to your pem file is not set. (APNS.pem = /path/to/cert.pem)" unless self.pem
    raise PemFileError, "The path to your pem file does not exist!" unless File.exist?(self.pem)
    
    context      = OpenSSL::SSL::SSLContext.new
    context.cert = OpenSSL::X509::Certificate.new(File.read(self.pem))
    context.key  = OpenSSL::PKey::RSA.new(File.read(self.pem), self.pass)

    sock         = TCPSocket.new(self.host, self.port)
    ssl          = OpenSSL::SSL::SSLSocket.new(sock,context)
    ssl.connect

    return sock, ssl
  end
  
  def self.feedback_connection
    raise "The path to your pem file is not set. (APNS.pem = /path/to/cert.pem)" unless self.pem
    raise "The path to your pem file does not exist!" unless File.exist?(self.pem)
    
    context      = OpenSSL::SSL::SSLContext.new
    context.cert = OpenSSL::X509::Certificate.new(File.read(self.pem))
    context.key  = OpenSSL::PKey::RSA.new(File.read(self.pem), self.pass)

    fhost = self.host.gsub!('gateway','feedback')
    puts fhost
    
    sock         = TCPSocket.new(fhost, 2196)
    ssl          = OpenSSL::SSL::SSLSocket.new(sock,context)
    ssl.connect

    return sock, ssl
  end
  
end
