require File.dirname(__FILE__) + '/../spec_helper'

describe APNS::Notification do
  
  it "should take a string as the message" do
    n = APNS::Notification.new('device_token', 'Hello')
    n.valid?.should == true
  end
  
  it "should take a hash as the message" do
    n = APNS::Notification.new('device_token', {:alert => 'Hello iPhone', :badge => 3})
    n.valid?.should == true
  end

  it "should not validate a message longer than 256 bytes" do
    n = APNS::Notification.new('device_token', {:alert => 'A' * 250})
    n.valid?.should == false
  end
  
  it "should validate a message of 256 bytes or less" do
    n = APNS::Notification.new('device_token', {:alert => 'A' * 236})
    n.packaged_message.size.to_i.should == 256
    n.valid?.should == true
  end
  
  describe '#packaged_message' do
    
    it "should return JSON with notification information" do
      n = APNS::Notification.new('device_token', {:alert => 'Hello iPhone', :badge => 2, :custom => "custom-string"})
      JSON.parse(n.packaged_message).should == { "aps" => { "badge" => 2, "alert" => 'Hello iPhone' }, "custom" => "custom-string" }
    end
    
    it "should not include keys that are empty in the JSON" do
      n = APNS::Notification.new('device_token', {:badge => 3})
      JSON.parse(n.packaged_message).should == { "aps" => { "badge" => 3 } }
    end
    
  end
  
  describe 'Device#to_payload' do
    it "should package the token" do
      n = APNS::Notification.new('<5b51030d d5bad758 fbad5004 bad35c31 e4e0f550 f77f20d4 f737bf8d 3d5524c6>', 'a')
      Base64.encode64(n.device.to_payload).should == "W1EDDdW611j7rVAEutNcMeTg9VD3fyDU9ze/jT1VJMY=\n"
    end
  end

  describe '#to_payload' do
    it "should package the token and message" do
      n = APNS::Notification.new('<5b51030d d5bad758 fbad5004 bad35c31 e4e0f550 f77f20d4 f737bf8d 3d5524c6>', {:alert => 'Hello iPhone'})
      Base64.encode64(n.to_payload).should == "AAAgW1EDDdW611j7rVAEutNcMeTg9VD3fyDU9ze/jT1VJMYAIHsiYXBzIjp7\nImFsZXJ0IjoiSGVsbG8gaVBob25lIn19\n"
    end
  end
  
end