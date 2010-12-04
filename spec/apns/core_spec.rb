require File.dirname(__FILE__) + '/../spec_helper'

describe APNS do
  
  describe "send_payload" do
    it "should complain about no pem file path" do
      lambda{APNS.send_payloads("payload")}.should raise_error(APNS::PemPathError)
    end
    
    it "should complain about pem file inexistence" do
      APNS.pem = "test.pem"
      lambda{APNS.send_payloads("payload")}.should raise_error(APNS::PemFileError)
    end
        
  end

end