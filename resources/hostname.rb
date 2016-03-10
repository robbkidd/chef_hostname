provides :hostname
resource_name :hostname

property :hostname, String, name_property: true
property :compile_time, [ true, false ], default: true

default_action :set

action :set do
  ohai "reload hostname" do
    plugin "hostname"
  end

  if node["platform_family"] != "windows"
    execute "set hostname to #{new_resource.hostname}" do
      command "/bin/hostname #{new_resource.hostname}"
      not_if { shell_out!("hostname").stdout.chomp == name }
      notifies :reload, "ohai[reload hostname]", :immediately
    end

    case node["platform_family"]
    when "rhel", "fedora"
      hostfile = "/etc/sysconfig/network"
      file hostfile do
        content IO.read(hostfile).gsub(/^HOSTNAME=.*$/, "HOSTNAME=#{new_resource.hostname}")
      end
    when "freebsd", "openbsd", "netbsd"
      rc_file = "/etc/rc.conf"
      rc_file_txt = IO.read(rc_file).split("\n")
      rc_file_txt.reject! { |s| s =~ /^\s+hostname\s+=/ }
      rc_file_txt += [ "hostname=#{new_resource.hostname}" ]
      file rc_file do
        content rc_file_txt.join("\n")
        owner "root"
        group node["root_group"]
        mode "0644"
        not_if { IO.read(rc_file) =~ /^hostname=#{new_resource.hostname}$/ }
      end

      file "/etc/myname" do
        content "#{new_resource.hostname}\n"
        owner "root"
        group node["root_group"]
        mode "0644"
      end
    when "debian"
      # Debian/Ubuntu/Mint/etc use /etc/hostname
      file "/etc/hostname" do
        content "#{new_resource.hostname}\n"
        owner "root"
        group node["root_group"]
        mode "0644"
      end
    when "suse"
      # SuSE/OpenSUSE uses /etc/HOSTNAME
      file "/etc/HOSTNAME" do
        content "#{new_resource.hostname}\n"
        owner "root"
        group node["root_group"]
        mode "0644"
      end
    else
      if node["os"] == "linux"
        # This is a failsafe for all other linux distributions where we set the hostname
        # via /etc/sysctl.conf on reboot.  This may get into a fight with other cookbooks
        # that manage sysctls on linux.

        sysctl = "/etc/sysctl.conf"
        file sysctl do
          owner "root"
          group node["root_group"]
          mode "0644"
          content IO.read(sysctl) + "kernel.hostname=#{new_resource.hostname}\n"
          not_if { IO.read(sysctl) =~ /^kernel\.hostname=#{new_resource.hostname}$/ }
        end
      else
        raise "Do not know how to set hostname on os #{node[:os]}, platform #{node[:platform]},"\
              "platform_version #{node[:platform_version]}, platoform_family #{node[:platform_family]}"

      end
    end

  else # windows

    # suppress EC2 config service from setting our hostname
    ec2_config_xml = 'C:\Program Files\Amazon\Ec2ConfigService\Settings\config.xml'
    cookbook_file ec2_config_xml do
      source "config.xml"
      only_if { File.exist? ec2_config_xml }
    end

    # update via netdom
    windows_batch "set hostname" do
      code <<-EOH
          netdom computername #{Socket.gethostname} /add:#{new_resource.hostname}
          netdom computername #{Socket.gethostname} /makeprimary:#{new_resource.hostname}
          netdom computername #{Socket.gethostname} /remove:#{Socket.gethostname}
          netdom computername #{Socket.gethostname} /remove:#{Socket.gethostbyname(Socket.gethostname).first}
      EOH
      not_if { Socket.gethostbyname(Socket.gethostname).first == "#{new_resource.hostname}" }
    end

    # reboot because $windows
    reboot "setting hostname" do
      reason "chef setting hostname"
      action :reboot_now
    end
  end
end

# this resource forces itself to run at compile_time
def after_created
  if compile_time
    Array(action).each do |action|
      self.run_action(action)
    end
  end
end
