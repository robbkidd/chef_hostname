#
# Cookbook Name:: fake
# Recipe:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

hostname "foobar.example.com"

file "/tmp/hostname-testing1" do
  content node["machinename"]
end

file "/tmp/hostname-testing2" do
  content `/bin/hostname`
end
