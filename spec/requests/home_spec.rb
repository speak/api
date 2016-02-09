require 'spec_helper.rb'

describe "API root" do
  it "should respond with success" do
    get '/'
    expect(last_response).to be_ok
    expect(last_json.ok).to eql(true)
    expect(last_json.message).to include("docs.speak.io")
  end
end
