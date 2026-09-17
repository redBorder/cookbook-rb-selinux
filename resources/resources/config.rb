# Cookbook:: rb-selinux
# Resource:: config

actions :add, :remove
default_action :add

# vsftpd (cookbook-vsftpd, config-snapshot backup/rollback feature): port
# labeling and fcontext for its config-backup transfer server. Applied in
# the :add action when ftp_enabled is true, unlabeled when false -- SELinux
# itself being on/off (which action runs) is orthogonal to whether FTP is.
attribute :ftp_enabled, kind_of: [TrueClass, FalseClass], default: false
attribute :ftp_pasv_min_port, kind_of: Integer, default: 21000
attribute :ftp_pasv_max_port, kind_of: Integer, default: 21010
attribute :ftp_upload_dir, kind_of: String, default: '/var/ftp/config-backups'
