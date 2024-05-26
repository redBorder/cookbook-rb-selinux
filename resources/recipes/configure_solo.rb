# Cookbook:: rb-selinux
# Recipe:: configure_solo
# Copyright:: 2024, redborder
# License:: Affero General Public License, Version 3

rb_selinux_config 'config' do
  action [:add]
end
