describe package('policycoreutils') do
  it { should be_installed }
end

describe service('selinux') do
  it { should be_enabled }
  it { should be_running }
end
