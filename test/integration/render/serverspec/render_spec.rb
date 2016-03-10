require "spec_helper"

describe "unit::render" do
  describe file("/tmp/hostname-testing1") do
    its(:content) { should match /foobar.example.com/ }
  end

  describe file("/tmp/hostname-testing2") do
    its(:content) { should match /foobar.example.com/ }
  end
end
