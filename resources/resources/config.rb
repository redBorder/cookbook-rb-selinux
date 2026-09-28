# Cookbook:: rb-selinux
# Resource:: config

actions :add, :remove, :add_ftp, :remove_ftp
default_action :add

# vsftpd (cookbook-vsftpd, config-snapshot backup/rollback feature): port
# labeling and fcontext for its config-backup transfer server. Separate
# actions (mirroring vsftpd_config's own :add_ftp/:remove_ftp) rather than
# an ftp_enabled property on :add/:remove, so the caller can invoke this
# after vsftpd_config has actually created ftp_upload_dir/incoming --
# :add runs unconditionally early in cookbook-rb-manager's recipe, well
# before that directory exists.
attribute :ftp_pasv_min_port, kind_of: Integer, default: 21000
attribute :ftp_pasv_max_port, kind_of: Integer, default: 21010
attribute :ftp_upload_dir, kind_of: String, default: '/var/ftp/config-backups'
