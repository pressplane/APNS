require File.dirname(__FILE__) + '/../spec_helper'

describe APNS do
  
  def valid_payload
    APNS::Payload.new("a-device-token", "my message")
  end
  
  describe "send_payload" do
    it "should complain about no pem file path" do
      lambda{APNS.send_payloads(valid_payload)}.should raise_error(APNS::PemPathError)
    end
    
    it "should complain about pem file inexistence" do
      APNS.pem = "test.pem"
      lambda{APNS.send_payloads(valid_payload)}.should raise_error(APNS::PemFileError)
      APNS.pem = nil # cleanup for next tests
    end
        
  end
  
  describe "feedback" do
    it "should complain about no pem file path" do
      lambda{APNS.feedback()}.should raise_error(APNS::PemPathError)
    end
    
    it "should complain about pem file inexistence" do
      APNS.pem = "test.pem"
      lambda{APNS.feedback()}.should raise_error(APNS::PemFileError)
      APNS.pem = nil # cleanup for next tests
    end
        
  end

end