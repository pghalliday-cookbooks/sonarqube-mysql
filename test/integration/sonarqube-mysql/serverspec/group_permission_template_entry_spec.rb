require 'serverspec'

set :backend, :exec
set :path, '/usr/bin:$PATH'

mysql_base_command = 'mysql -usonar -psonar -S /var/run/mysql-sonar/mysqld.sock sonar -e'

# user permission was removed from template for 'anyone' (NULL)
describe command(mysql_base_command + " \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IS NULL AND permission_reference = 'user'\"") do
  its(:stdout) { should match(/0/) }
end

# codeviewer permission was not removed from template for 'anyone' (NULL)
describe command(mysql_base_command + " \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IS NULL AND permission_reference = 'codeviewer'\"") do
  its(:stdout) { should match(/1/) }
end

# issueadmin permission was removed from template for 'sonar-administrators' group
describe command(mysql_base_command + " \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IN (SELECT id FROM groups WHERE name = 'sonar-administrators') AND permission_reference = 'issueadmin'\"") do
  its(:stdout) { should match(/0/) }
end

# admin permission was not removed from template for 'sonar-administrators' group
describe command(mysql_base_command + " \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IN (SELECT id FROM groups WHERE name = 'sonar-administrators') AND permission_reference = 'admin'\"") do
  its(:stdout) { should match(/1/) }
end

# issueadmin permission was added only once to template for 'anyone' (NULL)
describe command(mysql_base_command + " \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IS NULL AND permission_reference = 'issueadmin'\"") do
  its(:stdout) { should match(/1/) }
end

# user permission was added only once to template for 'sonar-users' group
describe command(mysql_base_command + " \"SELECT COUNT(*) FROM perm_templates_groups WHERE group_id IN (SELECT id FROM groups WHERE name = 'sonar-users') AND permission_reference = 'user'\"") do
  its(:stdout) { should match(/1/) }
end
