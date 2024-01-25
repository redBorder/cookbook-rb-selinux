%global cookbook_path /var/chef/cookbooks/rb-selinux

Name: cookbook-rb-selinux
Version: %{__version}
Release: %{__release}%{?dist}
BuildArch: noarch
Summary: redborder selinux cookbook to configure selinux in redborder environments

Requires: policycoreutils-python-utils libselinux-utils
BuildRequires: policycoreutils-python-utils libselinux-utils

License: AGPL 3.0
URL: https://github.com/redBorder/cookbook-rb-selinux
Source0: %{name}-%{version}.tar.gz

%description
%{summary}

%prep
%setup -qn %{name}-%{version}

%build
mkdir -p build
/usr/bin/checkmodule -M -m -o build/redborder-manager.mod resources/files/redborder-manager.te
/usr/bin/semodule_package -o build/redborder-manager.pp -m build/redborder-manager.mod

%install
mkdir -p %{buildroot}%{cookbook_path}
mkdir -p %{buildroot}/etc/selinux
cp -f -r  resources/* %{buildroot}%{cookbook_path}
chmod -R 0755 %{buildroot}%{cookbook_path}
install -D -m 0644 README.md %{buildroot}%{cookbook_path}/README.md
install -D -m 0644 build/redborder-manager.pp %{buildroot}/etc/selinux/

%pre

%post
case "$1" in
  1)
    # This is an initial install.
    :
  ;;
  2)
    # This is an upgrade.
    su - -s /bin/bash -c 'source /etc/profile && rvm gemset use default && env knife cookbook upload rb-selinux'
    semodule -l | grep redborder-manager &>/dev/null
    if [ $? -eq 0 ]; then
      semodule -r redborder-manager
    fi
    getenforce | grep Disabled &>/dev/null
    if [ $? -ne 0 ]; then
      semodule -i /etc/selinux/redborder-manager.pp
    fi 
  ;;
esac

%files
%defattr(0755,root,root)
%{cookbook_path}
%defattr(0644,root,root)
%{cookbook_path}/README.md
/etc/selinux/redborder-manager.pp

%doc

%changelog
* Fri Jan 19 2024 David Vanhoucke <dvanhoucke@redborder.com> - 0.0.2-1
- Fix druid coordinator
* Mon Nov 27 2023 David Vanhoucke <dvanhoucke@redborder.com> - 0.0.1-1
- first spec version
