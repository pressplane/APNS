require File.dirname(__FILE__) + '/../spec_helper'

describe APNS::Device do
  before do
    @device = APNS::Device.new('<5b51030d d5bad758 fbad5004 bad35c31 e4e0f550 f77f20d4 f737bf8d 3d5524c6>')
  end
  
  it "should cleanup the token string" do
    @device.token.should == "5b51030dd5bad758fbad5004bad35c31e4e0f550f77f20d4f737bf8d3d5524c6"
  end
  
  it "should package the token for the payload" do
    @device.to_payload.should == "[Q\003\r\325\272\327X\373\255P\004\272\323\\1\344\340\365P\367\177 \324\3677\277\215=U$\306"
  end
  
end