# chef_hostname Cookbook

Sets the hostname from within a recipe.  Supports FQDNs in the hostname.  Does not require lazy attributes in templates and 
file resources.

## Requirements

## Platforms
- Ubuntu/Debian
- RHEL/CentOS/Scientific/Oracle/Fedora
- OpenSUSE/SLES
- FreeBSD/OpenBSD/NetBSD

TODO:
- arch
- gentoo
- solaris
- aix
- nexus
- windows

### Chef
- Chef 12.1+

### Cookbooks
- compat_resource


## Custom Resources

hostname Sets the hostname, ensures that reboot will preserve the hostname, re-runs the ohai plugin to set the node data.

### Actions

- :set: Ses the hostname

### Properties

- hostname: hostname to set
- compile_time:  defaults to running at compile time, set to false to disable

## Examples

Setting hostname to a string:

```ruby
hostname "foo.example.com"
```

Setting hostname to the node name:

```ruby
hostname node.name
```

Setting hostname to whatever attribute you like:

```ruby
hostname node['set_fqdn']
```

There is no need to `lazy` arguments to templates and filenames when this is used since it forces itself to run at compile-time.

```ruby
hostname node.name

# node["fqdn"] will be set here at compile time
template "/etc/motd" do
  source "motd.erb"
  variables({
    fqdn: node["fqdn"]
  })
end

# /bin/hostname will be set here at compile time
myhostname = `/bin/hostname`

file "/etc/issue" do
  content myhostname
end
```

This cookbook does not set /etc/hosts entries, you can add `depends "hostfile"` to your metadata.rb and easily do that in your own recipe code (or you can roll your
own /etc/hosts template):

```ruby
hostname node.name

hostsfile_entry "localhost" do
  ip_address "127.0.0.1"
  hostname "localhost.localdomain"
  aliases [ "localhost" ]
  unique true
  action :create
end

hostsfile_entry 'set hostname' do
  ip_address node['ipaddress']
  hostname node['fqdn']
  aliases [ node['machinename'], node['hostname'] ]
  unique true
  action :create
end
```

## Notes

There are no recipes in this cookbook, the resource is meant to be used in your own custom recipes.  There are not attributes in this cookbook,
you can drive the resource off of whatever attribute you like.

## License & Authors

```
Author:: Lamont Granquist (<lamont@chef.io>)

Copyright:: 2016-2016, Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
