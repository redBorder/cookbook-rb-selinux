
# Cookbook Name:: rb-selinux
#
# Provider:: config
#

action :add do
  begin

    manager_module = 'redborder-manager'
    execute "semodule -i /etc/selinux/#{manager_module}.pp" do
      not_if "getenforce | grep Disabled"
      not_if "semodule -l | grep '^#{manager_module}\\s'"
    end

    ["nis_enabled", "domain_can_mmap_files"].each do |sebool|
      execute "setsebool -P #{sebool} 1" do
        not_if "getenforce | grep Disabled"
        not_if "getsebool #{sebool} | grep on$"
      end  
    end
    
    Chef::Log.info("rb-selinux cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end

action :remove do
  begin

    manager_module = 'redborder-manager'
    execute "semodule -r #{manager_module}" do
      only_if "getenforce | grep Disabled"
      only_if "semodule -l | grep '^#{manager_module}\\s'"
    end

    ["nis_enabled", "domain_can_mmap_files"].each do |sebool|
      execute "setsebool -P #{sebool} 0" do
        only_if "getenforce | grep Disabled"
        only_if "getsebool #{sebool} | grep on$"
      end  
    end

    Chef::Log.info("rb-selinux cookbook has been processed")
  rescue => e
    Chef::Log.error(e.message)
  end
end
