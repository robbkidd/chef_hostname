name             "chef_hostname"
maintainer       "Chef Software, Inc."
maintainer_email "cookbooks@chef.io"
license          "Apache 2.0"
description      "Configures the hostname on a node"
long_description IO.read(File.join(File.dirname(__FILE__), "README.md"))
version          "0.2.0"
source_url       "https://github.com/chef-cookbooks/chef-cookbooks" if respond_to?(:source_url)
issues_url       "https://github.com/chef-cookbooks/chef-cookbooks/issues" if respond_to?(:issues_url)

depends "compat_resource"

chef_version "~> 12.1" if respond_to?(:chef_version)
