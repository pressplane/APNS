require File.dirname(__FILE__) + '/../spec_helper'

describe APNS do
  
  describe "send_payload" do
    it "should complain about :sent not being a Proc" do
      lambda{APNS.send_payload("payload", :sent => [])}.should raise_error(/sent must be a Proc/)
    end
    
    it "should complain about :connection not being a Array or A Proc" do
      lambda{APNS.send_payload("payload", :connection => "")}.should raise_error(/connection must be either a Proc/)
    end
    
    it "should complain about no pem file path" do
      lambda{APNS.send_payload("payload")}.should raise_error(APNS::PemPathError)
    end
    
    it "should complain about pem file inexistence" do
      APNS.pem = "test.pem"
      lambda{APNS.send_payload("payload")}.should raise_error(APNS::PemFileError)
    end
    
    it "should complain about :connection not returning a Array of objects responding to #close" do
      lambda{APNS.send_payload("payload", :connection => [:a, :b])}.should raise_error(/should respond to #close/)
    end

    it "should complain about not being able to send the notification" do
      class A; def close;end;end
      lambda{APNS.send_payload("payload", :connection => [A.new, A.new])}.should raise_error(APNS::SendError)
    end

    it "should complain about :to_payload not being a Proc" do
      lambda{APNS.send_payload("payload", :to_payload => "")}.should raise_error(/to_payload must be a Proc/)
    end

    it "should complain about object not responding to #to_payload when :to_payload option is specified" do
      class A; def close;end;end
      lambda{APNS.send_payload("payload", :connection => [A.new, A.new], :to_payload => lambda{"A"})}.should raise_error(APNS::SendError)
    end
    
  end

end