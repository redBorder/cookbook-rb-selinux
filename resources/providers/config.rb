# Cookbook:: rb-selinux
# Provider:: config

action :add do
  begin

    dnf_package 'redborder-selinux' do
      action :upgrade
    end

    manager_module = shell_out('rpm -qa | grep redborder-manager').stdout.chomp.empty? ? '' : 'redborder-manager'
    ips_module = shell_out('rpm -qa | grep redborder-ips').stdout.chomp.empty? ? '' : 'redborder-ips'
    intrusion_module = shell_out('rpm -qa | grep redborder-intrusion').stdout.chomp.empty? ? '' : 'redborder-intrusion'
    proxy_module = shell_out('rpm -qa | grep redborder-proxy').stdout.chomp.empty? ? '' : 'redborder-proxy'

    # manager
    execute "semodule -i /etc/selinux/#{manager_module}.pp" do
      only_if { !manager_module.empty? && ::File.exist?("/etc/selinux/#{manager_module}.pp") }
      not_if 'getenforce | grep Disabled'
      not_if "semodule -l | grep '^#{manager_module}\\s'"
    end

    %w(nis_enabled domain_can_mmap_files).each do |sebool|
      execute "setsebool -P #{sebool} 1" do
        not_if { manager_module.empty? }
        not_if 'getenforce | grep Disabled'
        not_if "getsebool #{sebool} | grep on$"
      end
    end

    # ips
    execute "semodule -i /etc/selinux/#{ips_module}.pp" do
      only_if { !ips_module.empty? && ::File.exist?("/etc/selinux/#{ips_module}.pp") }
      not_if 'getenforce | grep Disabled'
      not_if "semodule -l | grep '^#{ips_module}\\s'"
    end

    # intrusion
    execute "semodule -i /etc/selinux/#{intrusion_module}.pp" do
      only_if { !intrusion_module.empty? && ::File.exist?("/etc/selinux/#{intrusion_module}.pp") }
      not_if 'getenforce | grep Disabled'
      not_if "semodule -l | grep '^#{intrusion_module}\\s'"
    end

    # TODO: restrict more the service snort (ips & intrusion)
    %w(snort_t).each do |service|
      execute "semanage permissive -a #{service}" do
        not_if { ips_module.empty? && intrusion_module.empty? }
        not_if 'getenforce | grep Disabled'
        not_if "semanage permissive -l | grep '#{service}'"
      end
    end

    # proxy
    execute "semodule -i /etc/selinux/#{proxy_module}.pp" do
      only_if { !proxy_module.empty? && ::File.exist?("/etc/selinux/#{proxy_module}.pp") }
      not_if 'getenforce | grep Disabled'
      not_if "semodule -l | grep '^#{proxy_module}\\s'"
    end

    Chef::Log.info('rb-selinux cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    manager_module = shell_out('rpm -qa | grep redborder-manager').stdout.chomp.empty? ? 'redborder-manager' : ''
    ips_module = shell_out('rpm -qa | grep redborder-ips').stdout.chomp.empty? ? 'redborder-ips' : ''
    intrusion_module = shell_out('rpm -qa | grep redborder-intrusion_module').stdout.chomp.empty? ? 'redborder-intrusion_module' : ''
    proxy_module = shell_out('rpm -qa | grep redborder-proxy').stdout.chomp.empty? ? 'redborder-proxy' : ''

    # manager
    execute "semodule -r #{manager_module}" do
      not_if { manager_module.empty? }
      only_if 'getenforce | grep Disabled'
      only_if "semodule -l | grep '^#{manager_module}\\s'"
    end

    %w(nis_enabled domain_can_mmap_files).each do |sebool|
      execute "setsebool -P #{sebool} 0" do
        not_if { manager_module.empty? }
        only_if 'getenforce | grep Disabled'
        only_if "getsebool #{sebool} | grep on$"
      end
    end

    # ips
    execute "semodule -r #{ips_module}" do
      not_if { ips_module.empty? }
      only_if 'getenforce | grep Disabled'
      only_if "semodule -l | grep '^#{ips_module}\\s'"
    end

    # proxy
    execute "semodule -r #{proxy_module}" do
      not_if { proxy_module.empty? }
      only_if 'getenforce | grep Disabled'
      only_if "semodule -l | grep '^#{proxy_module}\\s'"
    end

    # intrusion
    execute "semodule -r #{intrusion_module}" do
      not_if { intrusion_module.empty? }
      only_if 'getenforce | grep Disabled'
      only_if "semodule -l | grep '^#{intrusion_module}\\s'"
    end

    Chef::Log.info('rb-selinux cookbook has been processed')
  rescue => e
    Chef::Log.error(e.message)
  end
end
