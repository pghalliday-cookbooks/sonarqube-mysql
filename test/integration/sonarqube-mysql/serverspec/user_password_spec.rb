require 'serverspec'

set :backend, :exec
set :path, '/usr/bin:$PATH'

mysql_base_command = '/usr/bin/mysql -usonar -psonar -S /var/run/mysql-sonar/mysqld.sock sonar -e'

# admin password was updated
describe command(mysql_base_command + " \"SELECT COUNT(*) FROM users WHERE login = 'admin' AND crypted_password = 'c69266c47cf046c59db184fd299f26051f1e8b30' AND salt = '6522f3c5007ae910ad690bb1bdbf264a34884c6d'\"") do
  its(:stdout) { should match(/1/) }
end
