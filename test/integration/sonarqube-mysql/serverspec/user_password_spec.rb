require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.path = '/sbin:/usr/sbin'
  end
end

# admin password was updated
describe command("mysql -usonar -psonar sonar -e \"SELECT COUNT(*) FROM users WHERE login = 'admin' AND crypted_password = 'c69266c47cf046c59db184fd299f26051f1e8b30' AND salt = '6522f3c5007ae910ad690bb1bdbf264a34884c6d'\"") do
  it { should return_stdout(/1/) }
end
